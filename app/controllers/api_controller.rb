require "analytic_utils"
require "javascript_utils"

class ApiController < ApplicationController

  def index
    data_request = params[:data_request]
    timeframe = params[:timeframe]
    year = params[:year]

    if data_request == 'user_chart'
      prs_by_user = AnalyticUtils.get_pull_request_stats('u.login', 'num_prs', timeframe, year)
      prs_by_user_top_x = AnalyticUtils.top_x_with_rollup(prs_by_user, 'login', 'num_prs', 5, 'others')
      prs_by_user_pie_str = JavascriptUtils.get_pull_request_stats(prs_by_user_top_x, 'login', 'num_prs')
      render :text => prs_by_user_pie_str
    elsif data_request == 'user_table'
      prs_by_user = AnalyticUtils.get_pull_request_stats('u.login', 'num_prs', timeframe, year)
      @table_handle = "user_prs_table"
      @table_data = prs_by_user
      @label_header = "User"
      @data_header = "Contributions"
      @label_index_name = "login"
      @data_index_name = "num_prs"
      render :partial => "dashboard/hash_as_table"
    elsif data_request == 'company_chart'
      prs_by_company = AnalyticUtils.get_pull_request_stats('c.name', 'num_prs', timeframe, year)
      prs_by_company_top_x = AnalyticUtils.top_x_with_rollup(prs_by_company, 'name', 'num_prs', 5, 'others')
      prs_by_company_pie_str = JavascriptUtils.get_pull_request_stats(prs_by_company_top_x, 'name', 'num_prs')
      render :text => prs_by_company_pie_str
    elsif data_request == 'company_table'
      prs_by_company = AnalyticUtils.get_pull_request_stats('c.name', 'num_prs', timeframe, year)
      @table_handle = "company_prs_table"
      @table_data = prs_by_company
      @label_header = "Company"
      @data_header = "Contributions"
      @label_index_name = "name"
      @data_index_name = "num_prs"
      render :partial => "dashboard/hash_as_table"
    else
      render :text => "Error: Invalid data_request: #{data_request}"
    end
  end

end