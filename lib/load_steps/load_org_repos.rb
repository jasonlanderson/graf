require 'load_steps/load_step'
require 'load_steps/load_repo_users'
require 'load_steps/load_repo_pull_requests'
require 'load_steps/load_repo_commits'
require 'octokit_utils'
require 'log_level'
require 'constants'

class LoadOrgRepos < LoadStep  

  def name
    "Load Org Repos"
  end

  def execute(*args)
    raise ArgumentError, "Too many arguments" if args.length > 1
    org = args[0]
    puts "Start Step: #{name}"
  
    GithubLoad.log_current_msg("***Loading Repos", LogLevel::INFO)
    client = OctokitUtils.get_octokit_client
    
    if org.source == "org"
        repos = client.organization_repositories(org.login)
    elsif org.source == "user"
        repos = client.user(org.login)[:rels][:repos].get.data #organization_repositories(org.login)
    end
        
    total_repo_count = repos.count
    repos.each_with_index { |repo, index|
      unless Constants::REPOS_TO_SKIP.include?(repo[:attrs][:name])
        repo = Repo.create(
          :git_id => repo[:attrs][:id].to_i,
          :org_id => org.id,
          :name => repo[:attrs][:name],
          :full_name => repo[:attrs][:full_name],
          :fork => (repo[:attrs][:fork] == "true" ? true : false),
          :date_created => repo[:attrs][:date_created],
          :date_updated => repo[:attrs][:date_updated],
          :date_pushed => repo[:attrs][:date_pushed]
        )
        GithubLoad.log_current_msg("Loading Commits By Repo (#{index+1} / #{total_repo_count})", LogLevel::INFO)

        execute_load_steps(Constants::LOAD_STEPS_REPO, repo)

      end
    }

    puts "Finish Step: #{name}" 
  end

  def revert

  end
end