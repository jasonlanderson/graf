class GithubLoadMsg < ActiveRecord::Base
  belongs_to :github_load

  def self.getMsgs(load_id, last_msg_id=nil)
    # Get the lastest messages
    messages = GithubLoadMsg.where("github_load_id = #{load_id}")
    if last_msg_id
      messages = messages.where("id > #{last_msg_id}")
    end
    return messages
  end

  def to_s
    return "GithubLoadMsg=[#{msg}]"
  end
end
