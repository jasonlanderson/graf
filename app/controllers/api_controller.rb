require "analytic_utils"
require "javascript_utils"
require "db_utils"
require "date_utils"
require "rollup_methods"
require "csv"
require 'json'

LABEL_MAPPING = {
  "month"      => {sql_select: "#{DBUtils.get_month_by_name('pr.date_created')} month", sql_group_by: 'month', hash_name: 'month'},
  "quarter"    => {sql_select: "#{DBUtils.get_quarter_by_name('pr.date_created')} quarter", sql_group_by: 'quarter', hash_name: 'quarter'},  
  "year"       => {sql_select: "#{DBUtils.get_year('pr.date_created')} year", sql_group_by: 'year', hash_name: 'year'},
  "repository" => {sql_select: 'r.name', sql_group_by: 'r.name', hash_name: 'name'},
  "state"      => {sql_select: "#{DBUtils.get_state_select('pr.state', 'pr.date_merged')} state", sql_group_by: 'state', hash_name: 'state'},
  "company"    => {sql_select: 'c.name', sql_group_by: 'c.name', hash_name: 'name'},
  "user"       => {sql_select: 'u.login', sql_group_by: 'u.login', hash_name: 'login'},
  "name"       => {sql_select: 'u.name', sql_group_by: 'u.name', hash_name: 'name'},
  "timestamp"  => {sql_select: "UNIX_TIMESTAMP(STR_TO_DATE(DATE_FORMAT(pr.date_created, '01-%m-%Y'),'%d-%m-%Y')) epoch_timestamp", sql_group_by: 'epoch_timestamp', hash_name: 'timestamp'}
  #"org"        => {sql_select: 'r.org', }
}

DATA_MAPPING = {
  "prs"            => {sql_select: "COUNT(*) num_prs", hash_name: 'num_prs'},
  "avg_days_open"  => {sql_select: "IFNULL(ROUND(AVG(#{DBUtils.get_date_difference('pr.date_closed','pr.date_created')}), 1), 0)  avg_days_open", hash_name: 'avg_days_open'},
  "percent_merged" => {sql_select: "SUM( CASE WHEN pr.date_merged IS NOT NULL THEN 1 ELSE 0 END) /  (COUNT(*) * 0.01) percent_merged", hash_name: 'percent_merged'},
  "commits"        => {sql_select: "COUNT(*) num_commits", hash_name: 'num_commits'}
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
    search_criteria = params[:searchCriteria]



    select_columns = [ LABEL_MAPPING[group_by][:sql_select] ]
    group_by_columns = [ LABEL_MAPPING[group_by][:sql_group_by] ]



    if format == "line"
      select_columns << LABEL_MAPPING["timestamp"][:sql_select]
      group_by_columns << LABEL_MAPPING["timestamp"][:sql_group_by]
      puts "APPENDING COLUMNS #{select_columns}"
    end
    ###
    # Get the data
    ###
    case metric
    when 'prs', 'percent_merged', 'avg_days_open'
      # TODO: Might not be the best way to do this based on group by
      puts "Average days #{DATA_MAPPING[metric][:sql_select]}"
      puts "SELECT COLUMNS #{select_columns.class}, #{select_columns}"
      data = AnalyticUtils.get_pull_request_analytics(select_columns,
          DATA_MAPPING[metric][:sql_select],
          group_by_columns,
          DATA_MAPPING[metric][:hash_name],
          ROLLUP_METHODS["top_metric_vals"],
          rollup_count,
          search_criteria
        )
    when 'commits'
      data = AnalyticUtils.get_commit_analytics(select_columns,
          DATA_MAPPING[metric][:sql_select],
          group_by_columns,
          DATA_MAPPING[metric][:hash_name],
          search_criteria
        )
    else
      render :text => "Error: Unknown Metric '#{metric}'"
    end

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
        LABEL_MAPPING[group_by][:hash_name],
        DATA_MAPPING[metric][:hash_name],
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
      prs_data_pie_str = JavascriptUtils.get_pull_request_stats(data, LABEL_MAPPING[group_by][:hash_name], DATA_MAPPING[metric][:hash_name])
      #puts prs_data_pie_str
      render :json => prs_data_pie_str
    when 'bar'
      # TODO: Fix this as needed
      prs_data_pie_str = JavascriptUtils.get_pull_request_stats(data, LABEL_MAPPING[group_by][:hash_name], DATA_MAPPING[metric][:hash_name])
      render :json => prs_data_pie_str
    when 'line'
      # TODO: Need to add a javascript utils function to do this
      # line_graph = AnalyticUtils.get_timestamps(metric, LABEL_MAPPING[group_by][:sql_select],
      #           LABEL_MAPPING[group_by][:hash_name],
      #           rollup_count,
      #           search_criteria)
      # render :json => "{\"response\": #{line_graph}}"
    when 'table'
      @table_handle = "metric_table"
      @table_data = data
      @label_header = LABEL_MAPPING[group_by][:hash_name].titleize
      if metric == "commits"
        @data_header = "Commits"
      elsif metric == "prs"
        @data_header = "Pull Requests"
      elsif metric == "avg_days_open"
        @data_header ="Days"
      elsif metric == "percent_merged"
        @data_header ="Percentage"
      end          
      @label_index_name = LABEL_MAPPING[group_by][:hash_name]
      @data_index_name = DATA_MAPPING[metric][:hash_name]
      render :partial => "shared/hash_as_table"
    when 'csv'
      #puts "PARAMS #{params}"
      #puts "REQUEST #{request.inspect.to_s}"
      if params[:action] == "analytics_data"
      table = JavascriptUtils.get_pull_request_stats(data, LABEL_MAPPING[group_by][:hash_name], DATA_MAPPING[metric][:hash_name])
      #puts "TABLE #{table.to_s}" 

      #puts "TABLE_CLASS #{table.class}"
      
      # elsif params[:action] == "report_data"
      # table = AnalyticUtils.get_pull_request_data(params[:searchCriteria]) 
      # puts "TABLE_CLASS #{table.class}"
      # puts "TABLE #{table}"
      # puts "RESPONSE {\"response\": #{table.to_json}}" 
      # table = "{\"response\": #{table.to_json}}" #.to_s
      # puts "TABLE #{table}"
      end
      json = JSON.parse(table)
      csv_string = to_analytics_csv(json)
      #render :text => csv_string
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

  def to_analytics_csv(data)
    #puts "CSV #{data}"
    csv_string = CSV.generate do |csv|
      csv << ["Name", "Contributions"]
      Hash[data]["response"].each do |user|
        csv << [user["label"], user["data"]]
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