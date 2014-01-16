class DataViewerController < ApplicationController

  def index
    @pr_data = PullRequest.all()
  end
  
end