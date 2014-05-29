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
    #last_completed = GithubLoad.last_completed[:load_complete_time]
    #month = "0#{last_completed.month}" if last_completed.month.to_i < 10 # TODO, place in helpers
    #day = last_completed.day - 1
    #parsed_date = "#{last_completed.year}-#{month}-#{day}"
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
    #pull_requests.concat(client.pulls(repo.full_name, state = "closed"))
    if !pull_requests.nil? && pull_requests.length > 0
      pull_requests.each { |pull|
        record, user = nil
        # Make pull_requests hash keys accessible as symbols
        pr = pull.with_indifferent_access
        # Get user and insert if doesn't already exist
        user = LoadHelpers.create_user_if_not_exist(pr[:user]) if pr[:user]
        # Determine whether PR exists in our records
        record = PullRequest.find_by(git_id: pr[:id].to_i)
        puts "RECORD #{record}, ID #{pr[:id]} "
        if record
          puts "PR found! Updating #{pr[:number]} from #{repo[:full_name]}"
          # record.state = (date_merged.nil? ? pull[:state] : "merged")
          # record.date_merged = date_merged
          # record.date_updated = Time.now.utc
          # record.date_closed = pr[:date_closed] 
          # record.save
          LoadHelpers.update_pr(record, pr)              
        elsif !record
          puts "Adding new PR #{pr[:number]} from #{repo[:full_name]}"
          LoadHelpers.create_pr(repo, user, pr)
          # PullRequest.create(
          #   :repo_id => repo.id,
          #   :user_id => (user.nil? ? nil : user.id),
          #   :git_id => pr[:id].to_i,
          #   :pr_number => pr[:number],
          #   :body => pr[:body],
          #   :title => pr[:title],
          #   :date_created => pr[:created_at],
          #   :date_closed => pr[:closed_at],
          #   :date_updated => pr[:updated_at],
          #   :date_merged => pr[:merged_at],
          #   :state => (pr[:merged_at].nil? ? pr[:state] : "merged")
          #   )
        end
      }
    end
    pid, size = `ps ax -o pid,rss | grep -E "^[[:space:]]*#{$$}"`.strip.split.map(&:to_i)
    GithubLoad.log_current_msg("Memory before cleanup #{size} KB", LogLevel::INFO)
    pull_requests = nil
    GC.start
    pid, size = `ps ax -o pid,rss | grep -E "^[[:space:]]*#{$$}"`.strip.split.map(&:to_i)
    GithubLoad.log_current_msg("Memory after cleanup #{size} KB", LogLevel::INFO)

    puts "Finish Step: #{name}" 
  end

  def revert

  end
end
