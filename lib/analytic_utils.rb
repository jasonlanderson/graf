require "db_utils"
require "rollup_methods"

class AnalyticUtils

  # TODO: Change to use parameterized queries
  # NOTE: You cannot have multiple group_by's and also have show_rollup_remainder = true
  def self.get_analytics_data(label_columns, data_column, metric_tables, rollup_method, rollup_count, show_rollup_remainder, search_criteria = nil)

    select_label_cols = label_columns.map {|column| "#{column[:sql_select]} #{column[:alias]}"}
    group_by_label_cols = label_columns.map {|column| column[:alias]}
    select_data_col = "#{data_column[:sql_select]} #{data_column[:alias]}"

    # BASE QUERY
    base_query = "SELECT #{select_label_cols.join(", ")}, #{select_data_col} FROM #{metric_tables}"

    # If rolling up with multiple group bys, then add in the join
    # This can't be done in conjunction with show_rollup_remainder
    if rollup_count && label_columns.count > 1
      base_query += "INNER JOIN (SELECT #{select_label_cols[0]}, #{select_data_col} " \
        "FROM #{metric_tables} " \
        "WHERE #{label_columns[0][:sql_select]} IS NOT NULL " \
        "GROUP BY #{label_columns[0][:alias]} " \
        "ORDER BY #{data_column[:alias]} #{rollup_method[:sort_order]} " \
        "LIMIT #{rollup_count} ) " \
        "rollup_val_tbl ON rollup_val_tbl.#{label_columns[0][:alias]} = #{label_columns[0][:sql_select]} "
    end

    base_query += where_clause_stmt(search_criteria)
    base_query += "GROUP BY #{group_by_label_cols.join(", ")} "

    # If rolling up with multiple group bys then order by group bys
    if rollup_count && label_columns.count > 1
      base_query += "ORDER BY #{group_by_label_cols.join(", ")} "
    else
      base_query += "ORDER BY #{data_column[:alias]} #{rollup_method[:sort_order]} "
    end

    if rollup_count && show_rollup_remainder
      base_query += "LIMIT #{rollup_count} "
      top_x_query = base_query
      # TODO: Change SUM to other rollup_aggregation_method
      others_query = "(SELECT 'others' as #{label_columns[0][:alias]}, SUM(#{data_column[:alias]}) #{data_column[:alias]} FROM (#{base_query}, 18446744073709551615) others_tbl HAVING #{data_column[:alias]} IS NOT NULL)"
      sql_stmt = "(#{top_x_query}) UNION (#{others_query})"
    else
      sql_stmt = base_query
    end

    # TODO: rollup_method[:metric_related]

    return ActiveRecord::Base.connection.exec_query(sql_stmt)
  end

  def self.get_pull_request_data(search_criteria = nil)

    sql_stmt = "SELECT pr.pr_number, pr.title, pr.body, pr.state, IFNULL(NULLIF(u.name, ''), u.login) user_name, c.name company, r.name repo_name,  " \
      "r.full_name repo_full_name, pr.date_created, pr.date_closed, pr.date_merged, #{DBUtils.get_date_difference('pr.date_closed','pr.date_created')} days_open " \
      "FROM pull_requests pr " \
      "LEFT OUTER JOIN users u ON pr.user_id = u.id " \
      "LEFT OUTER JOIN companies c ON u.company_id = c.id " \
      "LEFT OUTER JOIN repos r ON pr.repo_id = r.id " \
      "LEFT OUTER JOIN orgs o ON r.org_id = o.id "

    sql_stmt += where_clause_stmt(search_criteria)

    sql_stmt += "ORDER BY user_name, pr.date_created"

    return ActiveRecord::Base.connection.exec_query(sql_stmt)
  end

  # Input array must be [{label_index_name => label, data_index_name => data}]
  def self.top_x_with_rollup(input_array, label_index_name, data_index_name, top_x_count, rollup_name, rollup_method)
    if top_x_count < 0
      top_x_count = 0
    end

    if top_x_count >= input_array.count
      return input_array
    end

    # Sort the array
    sorted_array = input_array.sort_by {|x| x[data_index_name] }.reverse

    # Calculate the remaining
    rollup_val = 0
    if rollup_method == ROLLUP_METHOD::SUM
      sorted_array[top_x_count..sorted_array.count].each {|x| rollup_val += x[data_index_name] }
    elsif rollup_method == ROLLUP_METHOD::AVG
      sorted_array[top_x_count..sorted_array.count].each {|x| rollup_val += x[data_index_name] }
      rollup_val = rollup_val / (sorted_array.count - top_x_count)
    else
      puts "ERROR: Unknown Rollup Method '#{rollup_method}'"
    end
    
    # Remove non-top
    result = sorted_array[0...top_x_count]

    # Add rollup record
    # Add the numbers for mysql
    result << {label_index_name => rollup_name, data_index_name => rollup_val}

    return result
  end

  def self.where_clause_stmt(search_criteria, metric = nil)

    # If there is no search criteria, just return
    puts "SEARCH CRITERIA #{search_criteria}"
    return "" unless search_criteria

    where_stmt = " WHERE 1=1 "

    if search_criteria[:month] && search_criteria[:month] != ''
      where_stmt += "AND #{DBUtils.get_month('pr.date_created')} = '#{search_criteria[:month]}' "
    end

    if search_criteria[:quarter] && search_criteria[:quarter] != ''
      case search_criteria[:quarter]
      when "q1"
        where_stmt += "AND #{DBUtils.get_month('pr.date_created')} IN ('01', '02', '03') "
      when "q2"
        where_stmt += "AND #{DBUtils.get_month('pr.date_created')} IN ('04', '05', '06') "
      when "q3"
        where_stmt += "AND #{DBUtils.get_month('pr.date_created')} IN ('07', '08', '09') "
      when "q4"
        where_stmt += "AND #{DBUtils.get_month('pr.date_created')} IN ('10', '11', '12') "
      end
    end

    if search_criteria[:year] && search_criteria[:year] != ''
      where_stmt += "AND #{DBUtils.get_year('pr.date_created')} = '#{search_criteria[:year]}' "
    end

    if search_criteria[:start_date] && search_criteria[:start_date] != ''
      start_date = search_criteria[:start_date]

      if start_date.include?("/")
        start_date = DateUtils.human_slash_date_format_to_db_format(start_date)
      end
      
      where_stmt += "AND pr.date_created >= '#{start_date}' "
    end

    if search_criteria[:end_date] && search_criteria[:end_date] != ''
      end_date = search_criteria[:end_date]
      
      if end_date.include?("/")
        end_date = DateUtils.human_slash_date_format_to_db_format(end_date)
      end

      where_stmt += "AND pr.date_created <= '#{end_date}'  "
    end

    if search_criteria[:repo] && search_criteria[:repo] != ''
      where_stmt += "AND r.name = '#{search_criteria[:repo]}' "
    end

    if search_criteria[:state]
      if search_criteria[:state] == 'open'
        where_stmt += "AND pr.state = 'open' "
      elsif search_criteria[:state] == 'merged'
        where_stmt += "AND pr.date_merged IS NOT NULL "
      elsif search_criteria[:state] == 'closed'
        # Not including merged prs
        where_stmt += "AND pr.state = 'closed' AND pr.date_merged IS NULL "
      end
    end

    if search_criteria[:company] && search_criteria[:company] != ''
      where_stmt += "AND c.name = '#{search_criteria[:company]}' "
    end

    if search_criteria[:user] && search_criteria[:user] != ''
      where_stmt += "AND u.login = '#{search_criteria[:user]}' "
    end

    if search_criteria[:name] && search_criteria[:name] != ''
      where_stmt += "AND u.name = '#{search_criteria[:name]}' "
    end

    if search_criteria[:org] && search_criteria[:org] != ''
      where_stmt += "AND o.login = '#{search_criteria[:org]}' "
    end
    return where_stmt
  end

  def self.get_state_stats(data)
    total = 0
    open = 0
    closed = 0
    merged = 0
    data.each { |x|
      total += 1
      if x['date_merged']
        merged += 1
      elsif x['date_closed']
        closed += 1
      else
        open += 1
      end
    }

    return {:total => total, :open => open, :closed => closed, :merged => merged}
  end
end