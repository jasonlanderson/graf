require "analytic_utils"
require "date_utils"

class DataViewerController < ApplicationController

  def index
    @pr_data = AnalyticUtils.get_pull_request_data()

    @pr_state_stats = AnalyticUtils.get_state_stats(@pr_data)

    @repos = Repo.order(:name)
    @companies = Company.order(:name).select('DISTINCT(name)')
    @users = User.order(:login)
  end
  
end