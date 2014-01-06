class GithubLoad < ActiveRecord::Base

  def log_msg(msg, log_level, log_date = Time.now)
    return GithubLoadMsg.create(:github_load_id => id,
      :msg => msg,
      :log_level => log_level,
      :log_date => log_date
      )
  end

  def self.last_completed()
    GithubLoad.where("load_complete_time IS NOT NULL").order("load_complete_time DESC").first
  end

end
