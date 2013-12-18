class PullRequest < ActiveRecord::Base
  belongs_to :repo
  belongs_to :user
  #attr_accessible :repo_id, :user_id, :git_id, :pr_number, :body, :title, :state, :date_created, :date_closed, :date_updated, :date_merged


end
