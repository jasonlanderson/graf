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
    @user_names = User.order(:name).select('DISTINCT(name)').where("name <> ''")
    @last_updated = GithubLoad.last
  end
  
end