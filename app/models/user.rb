class User < ActiveRecord::Base
  belongs_to :company
  has_and_belongs_to_many :commits
  def to_s
    return "User=[login: #{login}, name: #{name}]"
  end

  def to_json_with_company
    return "{\"git_id\": \"#{git_id}\", \"login\": \"#{login}\", \"name\": \"#{name}\", \"location\": \"#{location}\", \"email\": \"#{email}\", \"date_created\": \"#{date_created}\", \"date_updated\": \"#{date_updated}\", \"company\": \"#{company.name}\"}"
  end
end
