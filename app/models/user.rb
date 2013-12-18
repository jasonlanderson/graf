class User < ActiveRecord::Base
  belongs_to :company

  def to_s
    return "User=[login: #{login}, name: #{name}]"
  end
end
