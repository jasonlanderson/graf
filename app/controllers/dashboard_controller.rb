require "analytic_utils"
require "javascript_utils"

class DashboardController < ApplicationController

  def index
    @prs_by_user = AnalyticUtils.get_pull_request_stats('u.login', 'num_prs')
    prs_by_user_top_x = AnalyticUtils.top_x_with_rollup(@prs_by_user, 'login', 'num_prs', 5, 'others')
    @prs_by_user_pie_str = JavascriptUtils.get_pull_request_stats(prs_by_user_top_x, 'login', 'num_prs')
  
    @prs_by_company = AnalyticUtils.get_pull_request_stats('c.name', 'num_prs')
    prs_by_company_top_x = AnalyticUtils.top_x_with_rollup(@prs_by_company, 'name', 'num_prs', 5, 'Others')
    @prs_by_company_pie_str = JavascriptUtils.get_pull_request_stats(prs_by_company_top_x, 'name', 'num_prs')
  end

end