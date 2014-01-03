require "analytic_utils"
require "javascript_utils"

class ApiController < ApplicationController

  def index
    timeframe = params[:timeframe]
    year = params[:year]
    visual = "" # Chart or Table 
    @prs_by_user = AnalyticUtils.get_pull_request_stats('u.login', 'num_prs', timeframe, year)
    prs_by_user_top_x = AnalyticUtils.top_x_with_rollup(@prs_by_user, 'login', 'num_prs', 5, 'others')
    @prs_by_user_pie_str = JavascriptUtils.get_pull_request_stats(prs_by_user_top_x, 'login', 'num_prs')


    #render :text => @prs_by_user_pie_str

    @table_handle = "users_prs_table" 
	@table_data = @prs_by_user 
	@label_header = "User" 
	@data_header = "Contributions" 
	@label_index_name = "login" 
	@data_index_name = "num_prs" 
	render :template => "dashboard/_hash_as_table" # Returns table
  end

end