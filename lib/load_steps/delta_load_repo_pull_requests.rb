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
    parsed_date = "2014-05-27"
    pull_requests = nil
    begin
      #JSON.parse(HTTParty.get("https://api.github.com/search/issues?q=repo:cloudfoundry/bosh-lite+type:pr+updated:%3E2014-05-27+client_id:949149798908ec942301+client_secret:70563cd761fafd0df22b5f4cb40a68b2b9afc9f4", :headers => {"User-Agent" => "kkbankol"} ).body)["items"]
      #JSON.parse(HTTParty.get("https://api.github.com/search/issues?q=repo:cloudfoundry/bosh-lite+type:pr+updated:%3E2014-05-27", :headers => {"User-Agent" => "kkbankol"} ).body)["items"]
      sleep(3.0)
      #pull_requests = client.search_issues(repo.full_name, options = {:type => "pr", :updated => "2014-05-27"})[:items]
      pull_requests = JSON.parse(HTTParty.get("https://api.github.com/search/issues?q=repo:#{repo.full_name}+type:pr+updated:%3E#{parsed_date}", :headers => {"User-Agent" => "kkbankol"} ).body)["items"]
      puts "Making request to"
      puts "https://api.github.com/search/issues?q=repo:#{repo.full_name}+type:pr+updated:%3E#{parsed_date}"
      puts "PULL REQUESTS #{pull_requests}" if repo.full_name.include?("cloudfoundry/bosh-lite")
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
        #puts "NUMBER #{pr[:number]}, REPO_ID #{Repo.find_by(full_name: repo.full_name).id}, TITLE #{pr[:title]}"
        puts "NUMBER #{pr[:number]}, TITLE #{pr[:title]}"
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
    else
      puts "SKIPPED, NO PRS FOUND"
    end

    puts "Finish Step: #{name}" 
  end

  def revert

  end
end