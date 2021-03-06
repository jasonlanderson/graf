require "analytic_utils"
require "date_utils"

class ReportController < ApplicationController
  skip_before_filter :require_login

  def index
    @metric_data = AnalyticUtils.get_pull_request_data()

    @pr_state_stats = AnalyticUtils.get_state_stats(@metric_data)

    @repos = Repo.order(:name)
    @organizations = Org.order(:login).select('DISTINCT(login)')
    @companies = Company.order(:name).select('DISTINCT(name)')
    @user_logins = User.order(:login).select('DISTINCT(login)').where("login <> ''")
    @user_names = User.order(:name).select('DISTINCT(name)').where("name <> '' and name not like '___'")
    @last_updated = GithubLoad.last
    @load_completion_time = GithubLoad.last_completed["load_complete_time"]
  end
  
end