class PullRequest < ActiveRecord::Base
  belongs_to :repo
  belongs_to :user

  def self.get_github_pr_link(repo_name, pr_number)
    return "https://github.com/#{repo_name}/pull/#{pr_number}"
  end

end
