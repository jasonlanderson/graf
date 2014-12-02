require "db_utils"

class AnalyticUtils

  # NOTE: You cannot have multiple group_by's and also have show_rollup_remainder = true
  #
  # Table of possible analytics queries
  # -------------------------------------------------------------------------
  # | Rollup | Show Remainder |                   Result                    |
  # -------------------------------------------------------------------------
  # |    N   |       -        | No Limits needed                            |
  # |    Y   |       N        | Simple single limit case                    |
  # |    Y   |       N        | Cannot use limit so need to use inner query |
  # |    Y   |       Y        | Have to use two limit queries               |
  # |    Y   |       Y        | NOT SUPPORTED                               |
  # -------------------------------------------------------------------------
  def self.get_analytics_data(label_columns, data_column, metric_tables,
                              rollup_method, rollup_count, show_rollup_remainder,
                              order_via_group_bys, search_criteria = nil)

    sql_stmt = get_base_analytics_data(label_columns, data_column, metric_tables,
                              rollup_method, rollup_count, show_rollup_remainder,
                              order_via_group_bys, search_criteria, true)
    puts "AnalyticUtils::get_analytics_data: sql_stmt = #{sql_stmt}"
    # If we're planning to show the rollup remainder then we need to do the limit the other way
    if !rollup_count.nil? && show_rollup_remainder
      top_x_query = sql_stmt
      base_others_query = get_base_analytics_data(label_columns, data_column, metric_tables,
                            rollup_method, rollup_count, show_rollup_remainder,
                            order_via_group_bys, search_criteria, false) 

      others_query = "SELECT 'others' as #{label_columns[0][:alias]}, " \
        "#{data_column[:aggregation_method]}(#{data_column[:alias]}) #{data_column[:alias]}, " \
        "2 as ordering " \
        "FROM (#{base_others_query}) others_tbl " \
        "HAVING #{data_column[:alias]} IS NOT NULL "

      sql_stmt = "(#{top_x_query}) UNION (#{others_query}) "
      sql_stmt += order_by_rollup(label_columns, data_column, rollup_method, order_via_group_bys, true)
    end
  
    return ActiveRecord::Base.connection.exec_query(sql_stmt)
  end

  def self.get_base_analytics_data(label_columns, data_column, metric_tables,
                              rollup_method, rollup_count, show_rollup_remainder,
                              order_via_group_bys, search_criteria, inner_limit_top )
    select_label_cols = label_columns.map {|column| "#{column[:sql_select]} #{column[:alias]}"}
    sql_stmt = "SELECT #{select_label_cols.join(", ")}, #{data_column[:sql_select]} #{data_column[:alias]} "

    if inner_limit_top
      sql_stmt += ", 1 as ordering "
    end

    sql_stmt += "FROM #{metric_tables}"

    if !rollup_count.nil?
      sql_stmt += inner_join_rollup(label_columns, data_column, metric_tables,
                    rollup_method, rollup_count, search_criteria, inner_limit_top)
    end

    sql_stmt += where_clause_stmt(search_criteria)
    group_by_label_cols = label_columns.map {|column| column[:alias]}
    sql_stmt += "GROUP BY #{group_by_label_cols.join(", ")} "
    sql_outter_stmt = not_null_select(sql_stmt, group_by_label_cols)
   
    sql_outter_stmt += order_by_rollup(label_columns, data_column, rollup_method, order_via_group_bys)
    return sql_outter_stmt
  end

  def self.not_null_select(inner_sql, select_columns)
    new_columns = []
    select_columns.each do | column |
      new_columns.push("#{ column } IS NOT NULL")
    end
    return "SELECT * from ( #{ inner_sql } ) g where #{ new_columns.join(' AND ') } "
  end

  def self.inner_join_rollup(label_columns, data_column, metric_tables,
    rollup_method, rollup_count, search_criteria, inner_limit_top)

    inner_join = "INNER JOIN (SELECT #{label_columns[0][:sql_select]} #{label_columns[0][:alias]}, "
    metric_sql_select = data_column[:sql_select]
    metric_sql_alias = data_column[:alias]
    order_by = "ORDER BY #{data_column[:alias]} #{rollup_method[:sort_order]} "
    if rollup_method[:rollup_metric]
      metric_sql_select = rollup_method[:rollup_metric][:sql_select]
      metric_sql_alias = rollup_method[:rollup_metric][:alias]
      order_by = "ORDER BY #{rollup_method[:rollup_metric][:alias]} #{rollup_method[:sort_order]} "
    end

    inner_join += "#{metric_sql_select} #{metric_sql_alias} "

    inner_join += "FROM #{metric_tables} "
    inner_join += where_clause_stmt(search_criteria)
    inner_join += " AND #{label_columns[0][:sql_select]} IS NOT NULL " \
      "GROUP BY #{label_columns[0][:alias]} " \
      "#{order_by} "

    if inner_limit_top
      inner_join += "LIMIT #{rollup_count} "
    else
      inner_join += "LIMIT #{rollup_count}, 18446744073709551615 "
    end

    inner_join += ") rollup_val_tbl ON rollup_val_tbl.#{label_columns[0][:alias]} = #{label_columns[0][:sql_select]} "

    return inner_join
  end


  def self.order_by_rollup(label_columns, data_column, rollup_method, order_via_group_bys, ordering = false)

    order_by_stmt = "ORDER BY "

    # If this order by statment is for multiple queries then include the ordering column
    if ordering
      order_by_stmt += "ordering, "
    end

    # If rolling up with multiple group bys or if label should sort by group_by then order by group bys
    if order_via_group_bys || label_columns[0][:sort_by] == 'group_by'
      # TODO: Month is in here but not cronological
      group_by_label_cols = label_columns.map {|column| column[:alias]}
      group_by_order_str = group_by_label_cols.join(" #{rollup_method[:sort_order]}, ")
      return order_by_stmt + "#{group_by_order_str} #{rollup_method[:sort_order]} "
    else
      return order_by_stmt + "#{data_column[:alias]} #{rollup_method[:sort_order]} "
    end
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

  def self.where_clause_stmt(search_criteria, metric = nil)

    # If there is no search criteria, just return
    return "" unless search_criteria
    where_stmt = " WHERE 1=1 "

    #ActionController::Parameters.permit_all_parameters = true

    # When clicking on the "Uncheck All" button, 
    # search_criteria.each do |filter|
    #   puts "FILTER ARRAY #{filter}, VALUE #{filter[1]} , CLASS #{filter[1].class}"
    #   val = filter[1]
    #   #filter[1].is_a?(String) ?  :
    #   #filter.map! {|x| y.is_a?(String) ? Array[y] : y  ; puts y }
    #   if val.is_a?(String) #&& filter[1].strip.length == 0) #== "String"        
    #     filter.pop
    #     filter.push(Array[val])
    #   end
    #   puts "#{filter}"
    # end

    # puts "_________________________________"
    # search_criteria.each { |filter|
    #   puts "MODIFIED FILTER ARRAY #{filter}, VALUE #{filter[1]} , CLASS #{filter[1].class}"
    # }

    if search_criteria[:month] && search_criteria[:month].join != ''
      where_stmt += "AND #{DBUtils.get_month('pr.date_created')} IN ('#{DBUtils.esc_list(search_criteria[:month]).join("', '")}') "
    end

    if search_criteria[:quarter] && search_criteria[:quarter].join != ''
      where_stmt += "AND #{DBUtils.get_month('pr.date_created')} IN ("
      search_criteria[:quarter].each {|quarter|
        case quarter.downcase
          when "q1"
            where_stmt += "'01', '02', '03',"
          when "q2"
            where_stmt += "'04', '05', '06',"
          when "q3"
            where_stmt += "'07', '08', '09',"
          when "q4"
            where_stmt += "'10', '11', '12',"
        end
      }
      where_stmt = where_stmt.chop + ") "
    end

    if search_criteria[:year] && search_criteria[:year].join != ''
      where_stmt += "AND #{DBUtils.get_year('pr.date_created')} IN ('#{DBUtils.esc_list(search_criteria[:year]).join("', '")}') "
    end

    if search_criteria[:start_date] && search_criteria[:start_date] != ''
      start_date = search_criteria[:start_date]

      if start_date.include?("/")
        start_date = DateUtils.human_slash_date_format_to_db_format(start_date)
      end
      
      where_stmt += "AND pr.date_created >= '#{DBUtils.esc(start_date)}' "
    end

    if search_criteria[:end_date] && search_criteria[:end_date] != ''
      end_date = search_criteria[:end_date]
      
      if end_date.include?("/")
        end_date = DateUtils.human_slash_date_format_to_db_format(end_date)
      end

      where_stmt += "AND pr.date_created <= '#{DBUtils.esc(end_date)}'  "
    end

    if search_criteria[:repo] && search_criteria[:repo].join != ''
      where_stmt += "AND r.name IN ('#{DBUtils.esc_list(search_criteria[:repo]).join("', '")}') "
    end

    if search_criteria[:state] && search_criteria[:state].join != ''
      where_stmt += " AND " + get_state_criteria_clause(search_criteria[:state])
    end

    if search_criteria[:company] && search_criteria[:company].join != ''
      where_stmt += "AND c.name IN ('#{DBUtils.esc_list(search_criteria[:company]).join("', '")}') "
    end

    if search_criteria[:user_login] && search_criteria[:user_login].join != ''
      where_stmt += "AND u.login IN ('#{DBUtils.esc_list(search_criteria[:user_login]).join("', '")}') "
    end

    if search_criteria[:user_name] && search_criteria[:user_name].join != ''
      where_stmt += "AND u.name IN ('#{DBUtils.esc_list(search_criteria[:user_name]).join("', '")}') "
    end

    if search_criteria[:org] && search_criteria[:org].join != ''
      where_stmt += "AND o.login IN ('#{DBUtils.esc_list(search_criteria[:org]).join("', '")}') "
    end
    return where_stmt
  end

  def self.get_state_criteria_clause(states)
    state_where_stmt = "("
    states.each { |state|
      if state == 'open'
        state_where_stmt += " (pr.state = 'open') "
      elsif state == 'merged'
        state_where_stmt += " (pr.date_merged IS NOT NULL) "
      elsif state == 'closed' # Not including merged prs
        state_where_stmt += " (pr.state = 'closed' AND pr.date_merged IS NULL) "
      end
      state_where_stmt += " OR " unless state == states.last
    }
    return state_where_stmt + ")"
  end

  # TODO, we need to see why the below function is inaccurate
  # def self.get_state_stats(data)
  #   total = 0
  #   open = 0
  #   closed = 0
  #   merged = 0
  #   data.each { |x|
  #     total += 1
  #     if x['date_merged']
  #       merged += 1
  #     elsif x['date_closed']
  #       closed += 1
  #     else
  #       open += 1
  #     end
  #   }

  def self.get_state_stats(data)
    total = 0
    open = 0
    closed = 0
    merged = 0
    data.each { |x|
      total += 1
      if x['state'] == "merged"
        merged += 1
      elsif x['state'] == "closed"
        closed += 1
      elsif x['state'] == "open"
        open += 1
      end
    }

    return {:total => total, :open => open, :closed => closed, :merged => merged}
  end
end