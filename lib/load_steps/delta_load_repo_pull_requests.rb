require 'load_steps/load_step'
require 'octokit_utils'
require 'log_level'
require 'load_steps/load_helpers'

class DeltaLoadRepoPullRequests < LoadStep

  def name
    "Load Delta Repo Pull Requests"
  end

  def execute(*args)
    repo = args[0]
    puts "STARTING DELTA LOAD"
    puts "Start Step: #{name}"

    puts "---------"
    puts "--- Loading PRs for #{repo.full_name}"
    puts "---------"
    GithubLoad.log_current_msg("Loading PRs for #{repo.full_name}", LogLevel::INFO)
    client = OctokitUtils.get_octokit_client
    parsed_date = LoadHelpers.parse_last_load_date
    pull_requests = nil
    begin
      #pull_requests = client.search_issues("repo=#{repo.full_name}+type:pr")[:items] ; sleep(3.0) #.search_issues(repo.full_name, options = {:type => "pr", :updated => "2014-05-27"})[:items]
      # TODO Ideally the command above should work with Octokit, but HTML encoding seems to be inconsistent, as we cannot add the "updated" param here
      pull_requests = LoadHelpers.github_pulls(client, repo.full_name, state = "open")
      pull_requests.concat(LoadHelpers.github_pulls(client, repo.full_name, state = "closed"))
    #rescue => e
    rescue Exception 
      # TODO, these have been commented out because they'll crash and stop the load if given repo has no contribs
      #GithubLoad.log_current_msg("The following error occured...", LogLevel::INFO)
      #GithubLoad.log_current_msg(e, LogLevel::INFO)
      #GithubLoad.log_current_msg(e.backtrace.join("\n"), LogLevel::INFO)
      return nil
    end
    if !pull_requests.nil? && pull_requests.length > 0
      pull_requests.each { |pr|
        record, user = nil
        # Get user and insert if doesn't already exist
        user = LoadHelpers.create_user_if_not_exist(pr[:user]) if pr[:user]
        # Determine whether PR exists in our records
        record = PullRequest.find_by(pr_number: pr[:number], repo_id: Repo.find_by(full_name: repo.full_name).id)
        # If our search determines the current pull request is already in our database
        if record
          # Update pr record's state, dates, etc if record else
          LoadHelpers.update_pr(record, pr)              
        # If we do not find the current pull request in our records, insert it  
        else
          # Create new record of pr
          LoadHelpers.create_pr(repo, user, pr)
        end
      }
    end

    puts "Finish Step: #{name}" 
  end

  def revert

  end
end