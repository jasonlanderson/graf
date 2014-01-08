require "analytic_utils"
require "javascript_utils"

GROUP_BY_MAPPING = {
  "month"      => {sql_name: '', hash_name: ''},
  "quarter"    => {sql_name: '', hash_name: ''},  
  "year"       => {sql_name: '', hash_name: ''},
  "repository" => {sql_name: 'r.name', hash_name: 'name'},
  "state"      => {sql_name: '', hash_name: ''},
  "company"    => {sql_name: 'c.name', hash_name: 'name'},
  "user"       => {sql_name: 'u.login', hash_name: 'login'}
}

class ApiController < ApplicationController

  def index
    data_request = params[:data_request]
    metric = params[:metric]
    group_by = params[:group_by]
    month = params[:month]
    quarter = params[:quarter]
    year = params[:year]
    repo = params[:repo]
    state = params[:state]
    company = params[:company]
    user = params[:user]

    if data_request == 'prs_chart'
      #group_by = params[:group_by]
      #u.login vs c.name

      prs_by_user = AnalyticUtils.get_pull_request_stats(GROUP_BY_MAPPING[group_by][:sql_name], 'num_prs', month, quarter, year, repo, state, company, user)
      prs_by_user_top_x = AnalyticUtils.top_x_with_rollup(prs_by_user, GROUP_BY_MAPPING[group_by][:hash_name], 'num_prs', 5, 'others')
      prs_by_user_pie_str = JavascriptUtils.get_pull_request_stats(prs_by_user_top_x, GROUP_BY_MAPPING[group_by][:hash_name], 'num_prs')
      render :json => prs_by_user_pie_str
    elsif data_request == 'prs_table'
      prs_by_user = AnalyticUtils.get_pull_request_stats(GROUP_BY_MAPPING[group_by][:sql_name], 'num_prs', month, quarter, year, repo, state, company, user)
      @table_handle = "prs_table"
      @table_data = prs_by_user
      @label_header = GROUP_BY_MAPPING[group_by][:hash_name].titleize
      @data_header = "\# of Pull Requests"
      @label_index_name = GROUP_BY_MAPPING[group_by][:hash_name]
      @data_index_name = "num_prs"
      render :partial => "dashboard/hash_as_table"
    # elsif data_request == 'days_elapsed_table'
    #   avg_days_elapsed = AnalyticUtils.get_prs_days_elapsed
    #   @table_handle = "prs_days_elapsed_table"
    #   @table_data = avg_days_elapsed
    #   @label_header = "Company"
    #   @data_header = "Average Days Elapsed"
    #   render :partial => "dashboard/hash_as_table"
    # elsif data_request == 'monthly_line_graph'
    #   line_graph = AnalyticUtils.get_timestamps(quarter, year, repo, state)
    #   render :json => "{\"response\": #{line_graph}}"
    else
      render :text => "Error: Invalid data_request: #{data_request}"
    end
  end

end