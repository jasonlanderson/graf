require "db_utils"
require "rollup_methods"

class AnalyticUtils
  # TODO: Change to use parameterized queries
  def self.get_pull_request_stats(select_label_col, select_data_col, group_by_label_col,
    order_by_data_col, month = nil, quarter = nil, year = nil, start_date = nil, end_date = nil,
    repo=nil, state=nil, company=nil, user=nil)

    sql_stmt = "SELECT #{select_label_col}, #{select_data_col} FROM pull_requests pr " \
      "LEFT OUTER JOIN users u ON pr.user_id = u.id " \
      "LEFT OUTER JOIN companies c ON u.company_id = c.id " \
      "LEFT OUTER JOIN repos r ON pr.repo_id = r.id "

    sql_stmt += where_clause_stmt(month, quarter, year, start_date, end_date, repo, state, company, user)
      
    sql_stmt += "GROUP BY #{group_by_label_col} ORDER BY #{order_by_data_col} DESC"

    return ActiveRecord::Base.connection.exec_query(sql_stmt)
  end

  # TODO: Change to use parameterized queries
  def self.get_timestamps(select_col, group_by_col, month = nil, quarter = nil, year = nil,
    start_date = nil, end_date = nil, repo=nil, state=nil, company=nil, user=nil)

    sql_stmt = "SELECT #{select_col}, pr.date_created FROM pull_requests pr LEFT OUTER JOIN users u  ON pr.user_id " \
      " = u.id LEFT OUTER JOIN companies c ON u.company_id = c.id LEFT OUTER JOIN repos r ON pr.repo_id = r.id " 
    
    sql_stmt += where_clause_stmt(month, quarter, year, start_date, end_date, repo, state, company, user)

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
    top_group_bys = Hash[pr_dates_by_group.sort_by {|x, y| y.length }.reverse[0..4]]

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

  def self.where_clause_stmt(month = nil, quarter = nil, year = nil, start_date = nil,
    end_date = nil, repo=nil, state=nil, company=nil, user=nil)

    where_stmt = " WHERE 1=1 "

    if month && month != ''
      where_stmt += "AND #{DBUtils.get_month('pr.date_created')} = #{month} "
    end

    if quarter && quarter != ''
      case quarter
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

    if year && year != ''
      where_stmt += "AND #{DBUtils.get_year('pr.date_created')} = '#{year}' "
    end

    if start_date && start_date != ''
      where_stmt += "AND pr.date_created >= '#{start_date}' "
    end

    if end_date && end_date != ''
      where_stmt += "AND pr.date_created <= '#{end_date}'  "
    end

    if repo && repo != ''
      where_stmt += "AND r.name = '#{repo}' "
    end

    if state && (state == "open")
      where_stmt += "AND pr.state = 'open' "
    elsif state && (state == "merged")
      where_stmt += "AND pr.date_merged NOT NULL "
    elsif state && (state == "closed") # Not including merged prs
      where_stmt += "AND pr.state = 'closed' AND pr.date_merged IS NULL "
    end

    if company && company != ''
      where_stmt += "AND c.name = '#{company}' "
    end

    if user && user != ''
      where_stmt += "AND u.login = '#{user}' "
    end

    return where_stmt
  end
end