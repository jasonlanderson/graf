require "db_utils"
require "rollup_methods"

class AnalyticUtils
  # TODO: Change to use parameterized queries
  def self.get_pull_request_analytics(select_label_col, select_data_col, group_by_label_col,
    order_by_data_col, search_criteria = nil)

    sql_stmt = "SELECT #{select_label_col}, #{select_data_col} FROM pull_requests pr " \
      "LEFT OUTER JOIN users u ON pr.user_id = u.id " \
      "LEFT OUTER JOIN companies c ON u.company_id = c.id " \
      "LEFT OUTER JOIN repos r ON pr.repo_id = r.id " \
      "LEFT OUTER JOIN orgs o ON r.org_id = o.id "



    sql_stmt += where_clause_stmt(search_criteria)

    sql_stmt += "GROUP BY #{group_by_label_col} ORDER BY #{order_by_data_col} DESC"

    return ActiveRecord::Base.connection.exec_query(sql_stmt)
  end


  def self.get_commit_analytics(select_label_col, select_data_col, group_by_label_col,
    order_by_data_col, search_criteria = nil)

    sql_stmt = "SELECT #{select_label_col}, #{select_data_col} FROM commits_users c_u LEFT OUTER JOIN commits pr " \
               "ON c_u.commit_id = pr.id LEFT OUTER JOIN users u ON c_u.user_id = u.id LEFT OUTER JOIN companies c " \
               " ON c.id = u.company_id LEFT OUTER JOIN repos r ON pr.repo_id = r.id LEFT OUTER JOIN orgs o ON r.org_id = o.id "

    sql_stmt += where_clause_stmt(search_criteria)

    sql_stmt += "GROUP BY #{group_by_label_col} ORDER BY #{order_by_data_col} DESC"

    return ActiveRecord::Base.connection.exec_query(sql_stmt)
  end

  # TODO: Change to use parameterized queries
  def self.get_timestamps(metric_type, select_col, group_by_col, rollup, search_criteria = nil)

    case metric_type
    when "prs", "avg_days_open"
    sql_stmt = "SELECT #{select_col}, pr.date_created, FROM pull_requests pr LEFT OUTER JOIN users u  ON pr.user_id " \
      " = u.id LEFT OUTER JOIN companies c ON u.company_id = c.id LEFT OUTER JOIN repos r ON pr.repo_id = r.id LEFT OUTER " \
      " JOIN orgs o ON r.org_id = o.id " 
    when "commits"
    sql_stmt = "SELECT #{select_col}, pr.date_created FROM commits_users c_u LEFT OUTER JOIN commits pr " \
               "ON c_u.commit_id = pr.id LEFT OUTER JOIN users u ON c_u.user_id = u.id LEFT OUTER JOIN companies c " \
               " ON c.id = u.company_id LEFT OUTER JOIN repos r ON pr.repo_id = r.id LEFT OUTER JOIN orgs o ON r.org_id = o.id "  # This should have comm instead of pr, but the where_clause_stmt will break
    end

    sql_stmt += where_clause_stmt(search_criteria)

    query = ActiveRecord::Base.connection.exec_query(sql_stmt)  
    pr_dates_by_group = Hash.new

    # Loop through each record to create a hash of companies mapping to array of PR create dates
    query.each do |record|
      key = record[group_by_col].to_s
      if !pr_dates_by_group.has_key?(key)
        pr_dates_by_group[key] ||= []
      end
      pr_dates_by_group[key] << record['date_created']
    end

    # Get the top companies
    top_group_bys = Hash[pr_dates_by_group.sort_by {|x, y| y.length }.reverse[0..(rollup.to_i - 1)]]

    json_dataset = "["
    top_group_bys.each do |group_by_val, pr_date_created_arr|
      data = Hash.new(0)
      #y.inject(data) { |h,e| h[e] += 1; h }.select { |k,v| v > 1 }.inject({}) { |r, e| r[e.first] = e.last; r }
      pr_date_created_arr.each do |formatted_date|
        date_obj = Date.parse(formatted_date.to_s)
        timestamp =  Time.new(date_obj.year, date_obj.month)  # Converts 2013-13-09 to 1357027200
        data[timestamp] += 1
      end
      timestamp_contrib = []
      data.each { |timestamp, contribs| timestamp_contrib << ( Array [ (timestamp.to_i * 1000).to_s , contribs]) }
      timestamp_contrib =  timestamp_contrib.sort_by {|x, y| x}

      if json_dataset != "["
        json_dataset += ","
      end
      json_dataset += "  { \"label\": \"#{group_by_val}\", \"data\" : #{timestamp_contrib} }"
    end

    json_dataset += "]" 

    return json_dataset

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

  def self.where_clause_stmt(search_criteria)

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

    if search_criteria[:startDate] && search_criteria[:startDate] != ''
      start_date = search_criteria[:startDate]

      if start_date.include?("/")
        start_date = DateUtils.human_slash_date_format_to_db_format(start_date)
      end
      
      where_stmt += "AND pr.date_created >= '#{start_date}' "
    end

    if search_criteria[:endDate] && search_criteria[:endDate] != ''
      end_date = search_criteria[:endDate]
      
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