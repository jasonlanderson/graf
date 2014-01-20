class User < ActiveRecord::Base
  belongs_to :company
  has_and_belongs_to_many :commits
  def to_s
    return "User=[login: #{login}, name: #{name}]"
  end
end
