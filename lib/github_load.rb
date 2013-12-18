require 'octokit_utils'

class GithubLoad
  def self.load_repos()
  	client = OctokitUtils.get_octokit_client

    repos = client.organization_repositories("cloudfoundry")
    repos.each { |repo|
    	Repo.create(:git_id => repo[:attrs][:id].to_i,
    		:name => repo[:attrs][:name],
    		:full_name => repo[:attrs][:full_name],
    		:fork => (repo[:attrs][:fork] == "true" ? true : false),
    		:date_created => repo[:attrs][:date_created],
    		:date_update => repo[:attrs][:date_update],
    		:date_pushed => repo[:attrs][:date_pushed]
    		)
    }

  end

  def self.load_users()
  	client = OctokitUtils.get_octokit_client
  	
  end

  def self.load_prs()
  	client = OctokitUtils.get_octokit_client
  	
  end

  def self.load_companies()
  	client = OctokitUtils.get_octokit_client

  end
end