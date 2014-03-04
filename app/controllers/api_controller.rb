require "analytic_utils"
require "javascript_utils"
require "db_utils"
require "date_utils"
require "rollup_methods"
require "csv"
require 'json'

LABEL_MAPPING = {
  'month' => {
    sql_select: "#{DBUtils.get_month_by_name_with_number_prefix('pr.date_created')}",
    alias: 'month',
    sort_by: 'group_by',
    time_based: true
  },
  'quarter' => {
    sql_select: "#{DBUtils.get_quarter_by_name('pr.date_created')}",
    alias: 'quarter',
    sort_by: 'group_by',
    time_based: true
  },  
  'year' => {
    sql_select: "#{DBUtils.get_year('pr.date_created')}",
    alias: 'year',
    sort_by: 'group_by',
    time_based: true
  },
  'repository' => {
    sql_select: 'r.name',
    alias: 'repo_name',
    sort_by: 'metric',
    time_based: false
  },
  'state' => {
    sql_select: "#{DBUtils.get_state_select('pr.state', 'pr.date_merged')}",
    alias: 'state',
    sort_by: 'metric',
    time_based: false
  },
  'company' => {
    sql_select: 'c.name',
    alias: 'company_name',
    sort_by: 'metric',
    time_based: false
  },
  'user' => {
    sql_select: 'u.login',
    alias: 'user_login',
    sort_by: 'metric',
    time_based: false
  },
  'name' => {
    sql_select: 'u.name',
    alias: 'user_name',
    sort_by: 'metric',
    time_based: false
  },
  'timestamp' => {
    sql_select: "UNIX_TIMESTAMP(STR_TO_DATE(DATE_FORMAT(pr.date_created, '01-%m-%Y'),'%d-%m-%Y'))",
    alias: 'epoch_timestamp',
    sort_by: 'group_by',
    time_based: false
  }
}

METRIC_DETAILS = {
  'prs' => {
    base_metric: "prs",
    sql_select: "COUNT(*)",
    alias: 'num_prs',
    aggregation_method: 'SUM',
    rollup_method: 'top_metric_vals'
  },
  'avg_days_open' => {
    base_metric: "prs",
    sql_select: "IFNULL(ROUND(AVG(#{DBUtils.get_date_difference('pr.date_closed','pr.date_created')}), 1), 0) ",
    alias: 'avg_days_open',
    aggregation_method: 'AVG',
    rollup_method: 'top_pr_contributors'
  },
  'percent_merged' => {
    base_metric: "prs",
    sql_select: "SUM( CASE WHEN pr.date_merged IS NOT NULL THEN 1 ELSE 0 END) /  (COUNT(*) * 0.01)",
    alias: 'percent_merged',
    aggregation_method: 'AVG',
    rollup_method: 'top_pr_contributors'
  },
  'commits' => {
    base_metric: "commits",
    sql_select: "COUNT(*)",
    alias: 'num_commits',
    aggregation_method: 'SUM',
    rollup_method: 'top_metric_vals'
  }
}

BASE_METRIC_TABLES = {
  'prs' => "pull_requests pr " \
    "LEFT OUTER JOIN users u ON pr.user_id = u.id " \
    "LEFT OUTER JOIN companies c ON u.company_id = c.id " \
    "LEFT OUTER JOIN repos r ON pr.repo_id = r.id " \
    "LEFT OUTER JOIN orgs o ON r.org_id = o.id ",
  'commits' => "commits_users c_u " \
   "LEFT OUTER JOIN commits pr ON c_u.commit_id = pr.id " \
   "LEFT OUTER JOIN users u ON c_u.user_id = u.id " \
   "LEFT OUTER JOIN companies c ON c.id = u.company_id " \
   "LEFT OUTER JOIN repos r ON pr.repo_id = r.id " \
   "LEFT OUTER JOIN orgs o ON r.org_id = o.id "
}

# An empty rollup metric implies that the current metric is to be used
ROLLUP_METHODS = {
  'top_pr_contributors' => {
    rollup_metric: METRIC_DETAILS['prs'],
    sort_order: 'DESC'
  },
  'top_metric_vals' => {
    rollup_metric: nil,
    sort_order: 'DESC'
  },
  'lowest_metric_vals' => {
    rollup_metric: nil,
    sort_order: 'ASC'
  }
}

class ApiController < ApplicationController

  def analytics_data
    metric = params[:metric]
    format = params[:format]
    group_by = params[:groupBy]
    rollup_count = params[:rollupCount].to_i if params[:rollupCount]
    search_criteria = params[:searchCriteria]
    order_via_group_bys = false
    rollup_method_name = METRIC_DETAILS[metric][:rollup_method]

    show_rollup_remainder = false
    if (format == "pie" || format == "bar") && rollup_method_name == 'top_metric_vals'
      show_rollup_remainder = true
    end

    label_columns = [ LABEL_MAPPING[group_by] ]

    # If we're doing the line format add timestamp on as another group on
    if format == "line"
      label_columns << LABEL_MAPPING["timestamp"]
      order_via_group_bys = true
    end
    
    ###
    # Get the data
    ###
    data = AnalyticUtils.get_analytics_data(
        label_columns,
        METRIC_DETAILS[metric],
        BASE_METRIC_TABLES[METRIC_DETAILS[metric][:base_metric]],
        ROLLUP_METHODS[rollup_method_name],
        rollup_count,
        show_rollup_remainder,
        order_via_group_bys,
        search_criteria
      )

    ###
    # Do the formatting
    ###
    case format
    when 'pie'
      prs_data_pie_str = JavascriptUtils.get_pull_request_stats(data, LABEL_MAPPING[group_by][:alias], METRIC_DETAILS[metric][:alias])
      render :json => prs_data_pie_str
    when 'bar'
      # TODO: Change this to format the data on the server side and then send over the data
      prs_data_pie_str = JavascriptUtils.get_pull_request_stats(data, LABEL_MAPPING[group_by][:alias], METRIC_DETAILS[metric][:alias])
      render :json => prs_data_pie_str
    when 'line'
      puts "LINE JSON #{data.inspect}"
      line_graph = JavascriptUtils.get_flot_line_chart_json(data, LABEL_MAPPING[group_by][:alias], LABEL_MAPPING["timestamp"][:alias], METRIC_DETAILS[metric][:alias])
      render :json => "{\"response\": #{line_graph}}"
    when 'table'
      @table_handle = "metric_table"
      @table_data = data
      @label_header = LABEL_MAPPING[group_by][:alias].titleize
      if metric == "commits"
        @data_header = "Commits"
      elsif metric == "prs"
        @data_header = "Pull Requests"
      elsif metric == "avg_days_open"
        @data_header ="Days"
      elsif metric == "percent_merged"
        @data_header ="Percentage"
      end          
      @label_index_name = LABEL_MAPPING[group_by][:alias]
      @data_index_name = METRIC_DETAILS[metric][:alias]
      render :partial => "shared/hash_as_table"
    when 'csv'
      csv_string = to_analytics_csv(data, LABEL_MAPPING[group_by][:alias], METRIC_DETAILS[metric][:alias])
      send_data csv_string,
        :type => 'text/csv; charset=iso-8859-1; header=present',
        :disposition => "attachment; filename=users.csv",
        :x_sendfile=>true
    else
      render :text => "Error: Unknown Format '#{format}'"
    end
  end

  def report_data
    report = params[:report]
    search_criteria = params[:searchCriteria]
    data = AnalyticUtils.get_pull_request_data(search_criteria)
    if params[:file] && (params[:file] == 'csv')
      table = "{\"response\": #{data.to_json}}" #.to_s
      json = JSON.parse(table)
      csv_string = to_report_csv(json)
      #render :text => csv_string
      send_data csv_string,
        :type => 'text/csv; charset=iso-8859-1; header=present',
        :disposition => "attachment; filename=users.csv",
        :x_sendfile=>true         
    elsif report == 'prs'
      @table_data = data
      render :partial => "report/prs"
    elsif report == 'summary'
      @summary_table_data = AnalyticUtils.get_state_stats(data)
      render :partial => "report/prs_summary"
    end
  end

  def to_analytics_csv(data, label_index, val_index)
    csv_string = CSV.generate do |csv|
      csv << ["Name", "Contributions"]
      data.each do |user|
        csv << [user[label_index], user[val_index]]
      end
    end
    return csv_string    
  end


  def to_report_csv(data)
    csv_string = CSV.generate do |csv|
      csv << ["Number", "Title", "Body", "State", "Days Open", "User", "Company", "Repo", "Created", "Closed", "Merged"]
      Hash[data]["response"].each do |user|
        csv << [user["pr_number"], user["title"], user["body"], user["state"], user["days_open"], user["user_name"], user["company"], user["repo_name"], user["date_created"], user["date_closed"], user["date_merged"]] 
      end
    end
    return csv_string    
  end

end