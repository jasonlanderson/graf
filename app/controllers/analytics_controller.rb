require "analytic_utils"
require "javascript_utils"

class AnalyticsController < ApplicationController
  skip_before_filter :require_login

  def index
    # Get the search criteria options
    @repos = Repo.order(:name)
    @organizations = Org.order(:login).select('DISTINCT(login)')
    @companies = Company.order(:name).select('DISTINCT(name)')
    @users = User.order(:login).select('DISTINCT(login)').where("login <> ''")
    @names = User.order(:name).select('DISTINCT(name)').where("name <> ''")
    @last_updated = GithubLoad.last
  end

end