require "analytic_utils"
require "javascript_utils"
require "db_utils"
require "date_utils"
require "rollup_methods"
require "csv"
require 'json'

LABEL_MAPPING = {
  "month"      => {sql_select: "#{DBUtils.get_month_by_name('pr.date_created')}", alias: 'month'},
  "quarter"    => {sql_select: "#{DBUtils.get_quarter_by_name('pr.date_created')}", alias: 'quarter'},  
  "year"       => {sql_select: "#{DBUtils.get_year('pr.date_created')}", alias: 'year'},
  "repository" => {sql_select: 'r.name', alias: 'repo_name'},
  "state"      => {sql_select: "#{DBUtils.get_state_select('pr.state', 'pr.date_merged')}", alias: 'state'},
  "company"    => {sql_select: 'c.name', alias: 'company_name'},
  "user"       => {sql_select: 'u.login', alias: 'user_login'},
  "name"       => {sql_select: 'u.name', alias: 'user_name'},
  "timestamp"  => {sql_select: "UNIX_TIMESTAMP(STR_TO_DATE(DATE_FORMAT(pr.date_created, '01-%m-%Y'),'%d-%m-%Y'))", alias: 'epoch_timestamp'}
}

DATA_MAPPING = {
  "prs"            => {base_metric: "prs", sql_select: "COUNT(*) num_prs", alias: 'num_prs'},
  "avg_days_open"  => {base_metric: "prs", sql_select: "IFNULL(ROUND(AVG(#{DBUtils.get_date_difference('pr.date_closed','pr.date_created')}), 1), 0)  avg_days_open", alias: 'avg_days_open'},
  "percent_merged" => {base_metric: "prs", sql_select: "SUM( CASE WHEN pr.date_merged IS NOT NULL THEN 1 ELSE 0 END) /  (COUNT(*) * 0.01) percent_merged", alias: 'percent_merged'},
  "commits"        => {base_metric: "commits", sql_select: "COUNT(*) num_commits", alias: 'num_commits'}
}

BASE_METRIC_TABLES = {
  "prs" => "pull_requests pr " \
          "LEFT OUTER JOIN users u ON pr.user_id = u.id " \
          "LEFT OUTER JOIN companies c ON u.company_id = c.id " \
          "LEFT OUTER JOIN repos r ON pr.repo_id = r.id " \
          "LEFT OUTER JOIN orgs o ON r.org_id = o.id ",
  "commits" => "commits_users c_u " \
               "LEFT OUTER JOIN commits pr ON c_u.commit_id = pr.id " \
               "LEFT OUTER JOIN users u ON c_u.user_id = u.id " \
               "LEFT OUTER JOIN companies c ON c.id = u.company_id " \
               "LEFT OUTER JOIN repos r ON pr.repo_id = r.id " \
               "LEFT OUTER JOIN orgs o ON r.org_id = o.id "
}

ROLLUP_METHODS = {
  "top_pr_contributors"   => {},
  "top_metric_vals" => {metric_related: true, sort_order: "DESC"},
  "lowest_metric_vals"  => {metric_related: true, sort_order: "ASC"}
}

class ApiController < ApplicationController


  def analytics_data
    metric = params[:metric]
    format = params[:format]
    group_by = params[:groupBy]
    rollup_count = params[:rollupVal].to_i if params[:rollupVal]
    show_rollup_remainder = true if params[:showRollupRemainder] == "true"
    search_criteria = params[:searchCriteria]

    label_columns = [ LABEL_MAPPING[group_by] ]

    # If we're doing the line format add timestamp on as another group on
    if format == "line"
      label_columns << LABEL_MAPPING["timestamp"]
    end
    
    ###
    # Get the data
    ###
    puts "Average days #{DATA_MAPPING[metric][:sql_select]}"

    data = AnalyticUtils.get_analytics_data(
        label_columns,
        DATA_MAPPING[metric][:sql_select],
        BASE_METRIC_TABLES[DATA_MAPPING[metric][:base_metric]],
        DATA_MAPPING[metric][:alias],
        ROLLUP_METHODS["top_metric_vals"],
        rollup_count,
        show_rollup_remainder,
        search_criteria
      )

    ###
    # Rollup data if needed
    ###
=begin
    case format
     when 'pie', 'bar'
      # When this is an avg, we need to roll up with avg
      rollup_method = ROLLUP_METHOD::SUM
      if metric == 'avg_days_open' || metric == 'percent_merged'
        rollup_method = ROLLUP_METHOD::AVG
      end

      data = AnalyticUtils.top_x_with_rollup(data,
        LABEL_MAPPING[group_by][:alias],
        DATA_MAPPING[metric][:alias],
        rollup.to_i,
        'others',
        rollup_method
      )
    end
=end

    ###
    # Do the formatting
    ###
    case format
    when 'pie'
      prs_data_pie_str = JavascriptUtils.get_pull_request_stats(data, LABEL_MAPPING[group_by][:alias], DATA_MAPPING[metric][:alias])
      #puts prs_data_pie_str
      render :json => prs_data_pie_str
    when 'bar'
      # TODO: Fix this as needed
      prs_data_pie_str = JavascriptUtils.get_pull_request_stats(data, LABEL_MAPPING[group_by][:alias], DATA_MAPPING[metric][:alias])
      render :json => prs_data_pie_str
    when 'line'
      line_graph = JavascriptUtils.get_flot_line_chart_json(data, LABEL_MAPPING[group_by][:alias], DATA_MAPPING[metric][:alias])
      render :json => "{\"response\": #{line_graph}}"
      # TODO: Need to add a javascript utils function to do this
      # line_graph = AnalyticUtils.get_timestamps(metric, LABEL_MAPPING[group_by][:sql_select],
      #           LABEL_MAPPING[group_by][:alias],
      #           rollup_count,
      #           search_criteria)
      # 
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
      @data_index_name = DATA_MAPPING[metric][:alias]
      render :partial => "shared/hash_as_table"
    when 'csv'
      #puts "PARAMS #{params}"
      #puts "REQUEST #{request.inspect.to_s}"

      csv_string = to_analytics_csv(data, LABEL_MAPPING[group_by][:alias], DATA_MAPPING[metric][:alias])
      send_data csv_string,
        :type => 'text/csv; charset=iso-8859-1; header=present',
        :disposition => "attachment; filename=users.csv",
        :x_sendfile=>true
    else
      render :text => "Error: Unknown Format '#{format}'"
    end
  end

  def report_data
    #puts "PARAMS #{params}"
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
    #puts "CSV #{data}"
    csv_string = CSV.generate do |csv|
      csv << ["Name", "Contributions"]
      data.each do |user|
        csv << [user[label_index], user[val_index]]
      end
    end
    return csv_string    
  end


  def to_report_csv(data)
    #puts "CSV #{data}"
    csv_string = CSV.generate do |csv|
      csv << ["Number", "Title", "Body", "State", "Days Open", "User", "Company", "Repo", "Created", "Closed", "Merged"]
      #csv << ["Name", "Contributions"]
      Hash[data]["response"].each do |user|
        #csv << [user["label"], user["data"]]
        csv << [user["pr_number"], user["title"], user["body"], user["state"], user["days_open"], user["user_name"], user["company"], user["repo_name"], user["date_created"], user["date_closed"], user["date_merged"]] 
      end
    end
    return csv_string    
  end

end