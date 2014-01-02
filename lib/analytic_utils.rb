class AnalyticUtils
  def self.get_pull_request_stats(group_by_col, data_index_name)
  	sql_stmt = "SELECT #{group_by_col}, COUNT(*) #{data_index_name} FROM pull_requests pr " \
	  	"LEFT OUTER JOIN users u ON pr.user_id = u.id " \
	  	"LEFT OUTER JOIN companies c ON u.company_id = c.id " \
	  	"GROUP BY #{group_by_col} ORDER BY #{data_index_name} DESC"


	# sql_stmt += "WHERE "
	# filter. { |x|
	# }

  	results = ActiveRecord::Base.connection.execute(sql_stmt)
  	return results
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