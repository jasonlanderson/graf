require 'octokit_utils'

class GithubLoad

  ORG_NAME = "cloudfoundry"
  REPO_NAME = ORG_NAME + "/bosh"

  def self.load_repos()
  	client = OctokitUtils.get_octokit_client

    repos = client.organization_repositories(ORG_NAME)
    repos.each { |repo|
    	Repo.create(:git_id => repo[:attrs][:id].to_i,
    		:name => repo[:attrs][:name],
    		:full_name => repo[:attrs][:full_name],
    		:fork => (repo[:attrs][:fork] == "true" ? true : false),
    		:date_created => repo[:attrs][:date_created],
    		:date_updated => repo[:attrs][:date_updated],
    		:date_pushed => repo[:attrs][:date_pushed]
    		)
    }

  end

  def self.load_users()
  	client = OctokitUtils.get_octokit_client

    # To Finishes
    contributors = client.repo(@name)[:rels][:contributors]
    pull_requests.each { |pr|
      User.create(:login => pr[:attrs][:login])
    }
  end

  def self.load_all_prs()
    Repo.all().each { |repo|
      load_prs_for_repo(repo)
    }
  end

  def self.load_prs_for_repo(repo)
  	client = OctokitUtils.get_octokit_client

    pull_requests = client.pulls(repo.full_name, state = "open")
    pull_requests.concat(client.pulls(repo.full_name, state = "closed"))
    pull_requests.each { |pr|

      PullRequest.create(
        :repo_id => repo.id,
        :git_id => pr[:attrs][:id].to_i,
        :pr_number => pr[:attrs][:number],
        :body => pr[:attrs][:body],
        :title => pr[:attrs][:title],
        :state => pr[:attrs][:state],
        :date_created => pr[:attrs][:created_at],
        :date_closed => pr[:attrs][:closed_at],
        :date_updated => pr[:attrs][:updated_at],
        :date_merged => pr[:attrs][:merged_at]
        )
    }
  end

  def self.load_companies()
  	client = OctokitUtils.get_octokit_client

  end
end