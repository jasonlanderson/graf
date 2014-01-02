require "analytic_utils"
require "javascript_utils"

class ApiController < ApplicationController

  def index
    timeframe = params[:timeframe]
    year = params[:year]

    @prs_by_user = AnalyticUtils.get_pull_request_stats('u.login', 'num_prs', timeframe, year)
    prs_by_user_top_x = AnalyticUtils.top_x_with_rollup(@prs_by_user, 'login', 'num_prs', 5, 'others')
    @prs_by_user_pie_str = JavascriptUtils.get_pull_request_stats(prs_by_user_top_x, 'login', 'num_prs')
    render :text => @prs_by_user_pie_str
  end

end