require "analytic_utils"

class DataViewerController < ApplicationController

  def index
    @pr_data = AnalyticUtils.get_pull_request_data
  end
  
end