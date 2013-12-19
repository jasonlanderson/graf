require "analytic_utils"

class DashboardController < ApplicationController

  def index
    results = AnalyticUtils.get_pull_request_stats()
    @user_pie_data = "["
    results.each{ |rec|
      if @user_pie_data != "["
        @user_pie_data += ","
      end
      @user_pie_data += "{ label: \"#{rec['login']}\", data: #{rec['num_prs']} }"
    }
    @user_pie_data += "]"
  end
end