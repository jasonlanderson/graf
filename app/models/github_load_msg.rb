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

  # def to_json_with_log_date_formatted
  #   return "{\"id\": \"#{id}\"," \
  #     "\"log_level\": \"#{log_level}\"," \
  #     "\"msg\": \"#{JSON.encode(msg)}\"," \
  #     "\"log_date\": \"#{log_date}\"," \
  #     "\"log_date_formatted\": \"#{log_date.localtime.strftime("%m/%d/%Y %H:%M:%S")}\"," \
  #     "\"github_load_id\": \"#{github_load_id}\"}"
  # end

  def self.message_array_to_json_formatted(messages)
    toReturn = '['
    messages.each_with_index { |message, index|
      unless index == 0
        toReturn += ','
      end
      #toReturn += message.to_json_with_log_date_formatted
      toReturn += message.to_json
    }
    return toReturn + ']'
  end
end
