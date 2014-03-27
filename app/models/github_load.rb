class GithubLoad < ActiveRecord::Base

  @@current_load = nil

  def self.log_current_msg(msg, log_level)
    if @@current_load 
      return @@current_load.log_msg(msg, log_level)
    end
  end

  def self.set_current_load(current_load)
    @@current_load = current_load
  end

  def log_msg(msg, log_level, log_date = Time.now)
    load_msg = GithubLoadMsg.create(:github_load_id => id,
      :msg => msg,
      :log_level => log_level,
      :log_date => log_date
      )
    puts load_msg
    return load_msg
  end

  def self.last_completed()
    GithubLoad.where("load_complete_time IS NOT NULL").order("load_complete_time DESC").first
  end

  def to_s
    return "GithubLoad=[load_start_time: #{load_start_time}, load_complete_time: #{load_complete_time}, initial_load: #{initial_load}]"
  end

end
