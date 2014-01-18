require "analytic_utils"
require "date_utils"

class DataViewerController < ApplicationController

  def index
    @pr_data = AnalyticUtils.get_pull_request_data('', '', '', '', '',
    '', '', 'IBM', '')

    @pr_state_stats = AnalyticUtils.get_state_stats(@pr_data)
    puts "STATS = #{@pr_state_stats}"
  end
  
end