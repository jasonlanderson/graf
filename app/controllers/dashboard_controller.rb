require "analytic_utils"
require "javascript_utils"

class DashboardController < ApplicationController

  def index
    # pull_request data by company as the default
    @prs_data = AnalyticUtils.get_pull_request_stats('c.name', 'num_prs')
    prs_top_x = AnalyticUtils.top_x_with_rollup(@prs_data, 'name', 'num_prs', 5, 'Others')
    @prs_chart_str = JavascriptUtils.get_pull_request_stats(prs_top_x, 'name', 'num_prs')

    @prs_table_label_header = 'Company'
    @prs_table_data_header = 'Contributions'
    @prs_label_index_name = 'name'
    @prs_data_index_name = 'num_prs'

    #@avg_days_elapsed = AnalyticUtils.get_prs_days_elapsed

    @repos = Repo.order(:name)
    @companies = Company.order(:name)
    @users = User.order(:login)

    #@timestamps = AnalyticUtils.get_timestamps
  end
  
end