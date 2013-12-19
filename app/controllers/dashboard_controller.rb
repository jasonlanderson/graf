require "analytic_utils"
require "javascript_utils"

class DashboardController < ApplicationController

  def index
    prs_by_user = AnalyticUtils.get_pull_request_stats('u.login')
    prs_by_user_top_x = AnalyticUtils.top_x_with_rollup(prs_by_user, "login", "calculated_value", 5, "others")
    @prs_by_user_pie_str = JavascriptUtils.get_pull_request_stats(prs_by_user_top_x, 'login', 'calculated_value')
  
    prs_by_company = AnalyticUtils.get_pull_request_stats('c.name')
    prs_by_company_top_x = AnalyticUtils.top_x_with_rollup(prs_by_company, "name", "calculated_value", 5, "Others")
    @prs_by_company_pie_str = JavascriptUtils.get_pull_request_stats(prs_by_company_top_x, 'name', 'calculated_value')
  end

end