class DashboardController < ApplicationController

  def index

    results = ActiveRecord::Base.connection.execute("SELECT u.login, COUNT(*) num_prs FROM pull_requests pr LEFT OUTER JOIN users u ON pr.user_id = u.id  LEFT OUTER JOIN companies c ON u.company_id = c.id GROUP BY u.login ORDER BY num_prs LIMIT 15")
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
