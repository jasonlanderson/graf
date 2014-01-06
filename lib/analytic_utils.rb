class AnalyticUtils
  def self.get_pull_request_stats(group_by_col, data_index_name, timeframe = nil, year = nil, repo=nil, state=nil)
    sql_stmt = "SELECT #{group_by_col}, COUNT(*) #{data_index_name} FROM pull_requests pr " \
      "LEFT OUTER JOIN users u ON pr.user_id = u.id " \
      "LEFT OUTER JOIN companies c ON u.company_id = c.id " \
      "LEFT OUTER JOIN repos r ON pr.repo_id = r.id " \
      "WHERE 1 = 1 "

    if timeframe && timeframe != ''
      case timeframe
      when "q1"
        sql_stmt += "AND strftime('%m', pr.date_created) IN ('01', '02', '03') "
      when "q2"
        sql_stmt += "AND strftime('%m', pr.date_created) IN ('04', '05', '06') "
      when "q3"
        sql_stmt += "AND strftime('%m', pr.date_created) IN ('07', '08', '09') "
      when "q4"
        sql_stmt += "AND strftime('%m', pr.date_created) IN ('10', '11', '12') "
      end
    end

    if year && year != ''
      sql_stmt += "AND strftime('%Y', pr.date_created) IS '#{year}' "
    end

    if repo && repo != '' && repo != 'All'
      sql_stmt += "AND r.name IS '#{repo}' "
    end

    if state && (state == "open")
      sql_stmt += "AND pr.state IS 'open' "
    elsif state && (state == "merged")
      sql_stmt += "AND pr.date_merged NOT NULL "
    elsif state && (state == "closed") # Not including merged prs
      sql_stmt += "AND pr.state IS 'closed' AND pr.date_merged ISNULL "
    end
      
    sql_stmt += "GROUP BY #{group_by_col} ORDER BY #{data_index_name} DESC"

    return ActiveRecord::Base.connection.execute(sql_stmt)
  end

  def self.get_pr_days_elapsed
    sql_stmt = "SELECT c.name, round(avg(julianday(IFNULL(pr.date_closed, date('now'))) - " \
      "julianday(pr.date_created)), 1) avg_days_open FROM pull_requests pr LEFT OUTER JOIN users u " \
      "ON pr.user_id = u.id LEFT OUTER JOIN companies c ON u.company_id = c.id GROUP BY c.name ORDER " \
      "BY c.name"

    return ActiveRecord::Base.connection.execute(sql_stmt)

  end



  def self.get_timestamps
    sql_stmt = "SELECT c.name, pr.date_created FROM pull_requests pr LEFT OUTER JOIN users u  ON pr.user_id " \
      " = u.id LEFT OUTER JOIN companies c ON u.company_id = c.id "
    result = Hash.new
    query = ActiveRecord::Base.connection.execute(sql_stmt)  
    query.each do |x|
        result[x["name"]] ||= [] if !result.has_key?(x["name"])
        result[x["name"]] << x["date_created"]
    end

    datasets = "{"

    top_companies = result.sort_by {|x, y| y.length }.reverse[0..4]


    top_companies.each do |x, y|
      data = Hash.new(0)
      y.inject(data) { |h,e| h[e] += 1; h }.select { |k,v| v > 1 }.inject({}) { |r, e| r[e.first] = e.last; r }
      timestamp_contrib = []
      data.each { |x, y| timestamp_contrib << ( Array [ Time.new(Date.parse(x).year, Date.parse(x).month).to_i.to_s , y]) }
      datasets += "  \"#{x}\": { label: \"#{x}\", data : #{timestamp_contrib} }, "
    end
    #query.inject(data { |h,e| h[e] += 1; h }.select { |k,v| v > 1 }.inject({}) { |r, e| r[e.first] = e.last; r })
    datasets += "};" 
    #A.each { |x, y| B << ( Array [ Time.new(Date.parse(x).year, Date.parse(x).month).to_i.to_s , y]) }
    #result.each 
    return datasets

  end


  def self.top_x_with_rollup(input_array, label_index_name, data_index_name, top_x_count, rollup_name)
    if top_x_count < 0
      top_x_count = 0
    end

    if top_x_count >= input_array.length
      return input_array
    else
      # Sort the array
      sorted_array = input_array.sort_by {|x| x[data_index_name] }.reverse

      # Calculate sum of remaining
      rollup_val = 0
      sorted_array[top_x_count..sorted_array.length].each {|x| rollup_val += x[data_index_name] }

      # Remove non-top
      result = sorted_array[0...top_x_count]

      # Add rollup record

      result << {label_index_name => rollup_name, data_index_name => rollup_val}

      return result
    end
  end
end