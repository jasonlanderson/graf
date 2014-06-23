require 'load_steps/load_step'
require 'octokit_utils'
require 'log_level'
require 'load_steps/load_helpers'

class LoadRepoPullRequests < LoadStep

  def name
    "Load Repo Pull Requests"
  end

  def execute(*args)
    repo = args[0]
    puts "Start Step: #{name}"

    puts "---------"
    puts "--- Loading PRs for #{repo.full_name}"
    puts "---------"
    GithubLoad.log_current_msg("Loading PRs for #{repo.full_name}", LogLevel::INFO)
    

    client = OctokitUtils.get_octokit_client
    pid, size = `ps ax -o pid,rss | grep -E "^[[:space:]]*#{$$}"`.strip.split.map(&:to_i)
    GithubLoad.log_current_msg("Initial memory before cleanup #{size} KB", LogLevel::INFO)
    begin
      # Fetch all pull requests for current repo from Github
      pull_requests = client.pulls(repo.full_name, state = "open")
      pull_requests.concat(client.pulls(repo.full_name, state = "closed"))     
    rescue Exception
      # GithubLoad.log_current_msg("The following error occured...", LogLevel::INFO)
      # GithubLoad.log_current_msg(e.message, LogLevel::INFO)
      # GithubLoad.log_current_msg(e.backtrace.join("\n"), LogLevel::INFO)
      #return nil  
    end
    pull_requests.each { |pr|
      # Get user and create a record, if it doesn't already exist
      user = LoadHelpers.create_user_if_not_exist(pr[:attrs][:user]) if pr[:attrs][:user]
      LoadHelpers.create_pr(repo, user, pr)
    }

    puts "Finish Step: #{name}" 
  end

  def revert

  end
end