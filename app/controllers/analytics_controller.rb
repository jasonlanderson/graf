require "analytic_utils"
require "javascript_utils"

class AnalyticsController < ApplicationController
  skip_before_filter :require_login

  def index
    # Get the search criteria options
    @repos = Repo.order(:name)
    @organizations = Org.order(:login).select('DISTINCT(login)')
    @companies = Company.order(:name).select('DISTINCT(name)')
    @user_logins = User.order(:login).select('DISTINCT(login)').where("login <> ''")
    @user_names = User.order(:name).select('DISTINCT(name)').where("name <> '' and name not like '___'")
    @last_updated = GithubLoad.last
  end

end