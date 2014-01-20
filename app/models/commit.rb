class Commit < ActiveRecord::Base
  belongs_to :repo
  has_and_belongs_to_many :users
end
