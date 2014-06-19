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
      #JSON.parse(HTTParty.get("https://api.github.com/search/issues?q=repo:cloudfoundry/bosh-lite+type:pr+updated:%3E2014-05-27", :headers => {"User-Agent" => "kkbankol"} ).body)["items"]
      # Ideally this should work with Octokit, but HTML encoding seems to be inconsistent, as we cannot add the "updated" param here
      #pull_requests = client.search_issues("repo=#{repo.full_name}+type:pr")[:items] ; sleep(3.0) #.search_issues(repo.full_name, options = {:type => "pr", :updated => "2014-05-27"})[:items]
      # Will just pull all prs for the moment
      pull_requests = client.pulls(repo.full_name, state = "open")
      pull_requests.concat(client.pulls(repo.full_name, state = "closed"))
    #rescue => e
    rescue Exception => e #=> Octokit::NotFound
      #GithubLoad.log_current_msg("The following error occured...", LogLevel::ERROR)
      #GithubLoad.log_current_msg(e, LogLevel::ERROR)
      #GithubLoad.log_current_msg(e.backtrace.join("\n"), LogLevel::ERROR)
      return nil
    end
    if !pull_requests.nil? && pull_requests.length > 0
      pull_requests.each { |pr|
        record, user = nil
        # Get user and insert if doesn't already exist
        user = LoadHelpers.create_user_if_not_exist(pr[:user]) if pr[:user]
        # Determine whether PR exists in our records
        record = PullRequest.find_by(pr_number: pr[:number], repo_id: Repo.find_by(full_name: repo.full_name).id)
        puts "RECORD #{record}, ID #{pr[:id]} "
        # if record
        #   puts "PR found! Updating #{pr[:number]} from #{repo[:full_name]}"
        #   LoadHelpers.update_pr(record, pr)              
        # else
        #   puts "Adding new PR #{pr[:number]} from #{repo[:full_name]}"
        #   LoadHelpers.create_pr(repo, user, pr)
        # end
        if record
          puts "Updating PR #{pr[:number]} from #{repo[:full_name]}"
          record.state = (pr[:merged_at].nil? ? pr[:state] : "merged")
          record.date_merged = pr[:merged_at]
          record.date_closed = pr[:closed_at]
          record.save
          puts "STATE UPDATED #{PullRequest.find_by(pr_number: pr[:number], repo_id: Repo.find_by(full_name: repo.full_name).id).state}"
        elsif !record
          puts "Adding new PR #{pr[:number]} from #{repo[:full_name]}"
          PullRequest.create(
            :repo_id => repo.id,
            :user_id => (user.nil? ? nil : user.id),
            :git_id => pr[:id].to_i,
            :pr_number => pr[:number],
            :body => pr[:body],
            :title => pr[:title],
            :date_created => pr[:created_at],
            :date_closed => pr[:closed_at],
            :date_updated => pr[:updated_at],
            :date_merged => pr[:merged_at],
            :state => (pr[:merged_at].nil? ? pr[:state] : "merged")
            )
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