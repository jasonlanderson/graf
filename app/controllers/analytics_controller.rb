require "analytic_utils"
require "javascript_utils"
require "rollup_methods"

class AnalyticsController < ApplicationController

  def index
    # pull_request data by company as the default
    # @metric_data = AnalyticUtils.get_pull_request_analytics('c.name', 'COUNT(*) num_prs', 'c.name', 'num_prs')
    # prs_top_x = AnalyticUtils.top_x_with_rollup(@metric_data, 'name', 'num_prs', 5, 'Others', ROLLUP_METHOD::SUM)
    # @chart_data_str = JavascriptUtils.get_pull_request_stats(prs_top_x, 'name', 'num_prs')

    # @table_label_header = 'Company'
    # @table_data_header = 'Contributions'
    # @label_index_name = 'name'
    # @data_index_name = 'num_prs'

    @repos = Repo.order(:name)
    @companies = Company.order(:name).select('DISTINCT(name)')
    @users = User.order(:login).select('DISTINCT(login)')

    @last_updated = GithubLoad.last
  end

end