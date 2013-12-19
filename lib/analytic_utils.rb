class AnalyticUtils
  def self.get_pull_request_stats(filter)
  	sql_stmt = "SELECT u.login, COUNT(*) num_prs FROM pull_requests pr " \
	  	"LEFT OUTER JOIN users u ON pr.user_id = u.id " \
	  	"LEFT OUTER JOIN companies c ON u.company_id = c.id " \
	  	"GROUP BY u.login ORDER BY num_prs DESC LIMIT 15"

	# sql_stmt += "WHERE "
	# filter. { |x|

	# }

  	results = ActiveRecord::Base.connection.execute(sql_stmt)
  	return results
  end
end