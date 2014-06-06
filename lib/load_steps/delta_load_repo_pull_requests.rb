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
    pid, size = `ps ax -o pid,rss | grep -E "^[[:space:]]*#{$$}"`.strip.split.map(&:to_i)
    GithubLoad.log_current_msg("Initial memory before cleanup #{size} KB", LogLevel::INFO)
    parsed_date = LoadHelpers.parse_last_load_date
    parsed_date = "2014-05-27"
    pull_requests = nil
    begin
      pull_requests = JSON.parse(HTTParty.get("https://api.github.com/search/issues?q=repo:#{repo.full_name}+type:pr+updated:%3E#{parsed_date}", :headers => {"User-Agent" => "kkbankol"} ).body)["items"]
    rescue => e
      GithubLoad.log_current_msg("The following error occured...", LogLevel::ERROR)
      GithubLoad.log_current_msg(e, LogLevel::ERROR)
      GithubLoad.log_current_msg(e.backtrace.join("\n"), LogLevel::ERROR)
      return nil  
    end
    if !pull_requests.nil? && pull_requests.length > 0
      pull_requests.each { |pull|
        record, user = nil
        # Make pull_requests hash keys accessible as symbols
        pr = pull.with_indifferent_access
        # Get user and insert if doesn't already exist
        user = LoadHelpers.create_user_if_not_exist(pr[:user]) if pr[:user]
        # Determine whether PR exists in our records
        record = PullRequest.find_by(pr_number: pr[:number], repo_id: Repo.find_by(full_name: repo.full_name).id) #git_id: pr[:id].to_i)
        puts "RECORD #{record}, ID #{pr[:id]} "
        if record
          puts "PR found! Updating #{pr[:number]} from #{repo[:full_name]}"
          LoadHelpers.update_pr(record, pr)              
        elsif !record
          puts "Adding new PR #{pr[:number]} from #{repo[:full_name]}"
          LoadHelpers.create_pr(repo, user, pr)
        end
      }
    end

    puts "Finish Step: #{name}" 
  end

  def revert

  end
end
