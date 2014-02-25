require 'load_steps/load_step'
require 'load_steps/load_org_repos'
require 'octokit_utils'
require 'log_level'
require 'constants'

class LoadOrgs < LoadStep

  def name
    "Load Orgs"
  end

  def execute(*args)
    puts "Start Step: #{name}"

    # Load all orgs
    client = OctokitUtils.get_octokit_client
    Constants.get_orgs.each { |org_hash|
      GithubLoad.log_current_msg("Loading Organization '#{org_hash["name"]}'", LogLevel::INFO)
      org_load_time = Time.now
      
      organization = client.user(org_hash["name"])

      org = Org.create(
        :git_id => organization[:attrs][:id].to_i,
        :name => organization[:attrs][:name],
        :login => organization[:attrs][:login],
        :date_created => organization[:attrs][:date_created],
        :date_updated => organization[:attrs][:date_updated],
        :org_type => org_hash["org_type"]
      )
      
      (LoadOrgRepos.new).execute(org, org_hash["repos_to_skip"])
      GithubLoad.log_current_msg("Organization '#{org.login}' took #{Time.now - org_load_time} to load", LogLevel::INFO)
    }
    

    puts "Finish Step: #{name}"    
  end

  def revert

  end
end