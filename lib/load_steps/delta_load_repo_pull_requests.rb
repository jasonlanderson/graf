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
    last_completed = GithubLoad.last_completed[:load_complete_time]
    parsed_date = "#{last_completed.year}-#{last_completed.month}-#{last_completed.day}"
    begin
      #pull_requests = client.pulls(repo.full_name, state = "open")
      pull_requests = JSON.parse(HTTParty.get("https://api.github.com/search/issues?q=repo:#{repo.full_name}+type:pr+updated:%3E#{parsed_date}", :headers => {"User-Agent" => "kkbankol"} ).body)["items"]
    rescue => e
      GithubLoad.log_current_msg("The following error occured...", LogLevel::ERROR)
      GithubLoad.log_current_msg(e.message, LogLevel::ERROR)
      GithubLoad.log_current_msg(e.backtrace.join("\n"), LogLevel::ERROR)
      return nil  
    end
    #pull_requests.concat(client.pulls(repo.full_name, state = "closed"))
    pull_requests.each { |pull|
      record, user = nil
      # Make pull_requests hash keys accessible as symbols
      pr = pull.with_indifferent_access
      # Get user and insert if doesn't already exist
      user = LoadHelpers.create_user_if_not_exist(pr[:attrs][:user]) if pr[:attrs][:user]
      # Determine whether PR exists in our records
      record = PullRequest.find_by(git_id: pull[:id].to_i)
      if record
        puts "Updating PR #{pull[:number]} from #{repo[:full_name]}"
        record.state = (date_merged.nil? ? pull[:state] : "merged")
        record.date_merged = date_merged
        record.date_updated = Time.now.utc
        record.date_closed = pull[:date_closed] 
        record.save              
      elsif !record
        PullRequest.create(
          :repo_id => repo.id,
          :user_id => (user.nil? ? nil : user.id),
          :git_id => pr[:attrs][:id].to_i,
          :pr_number => pr[:attrs][:number],
          :body => pr[:attrs][:body],
          :title => pr[:attrs][:title],
          :date_created => pr[:attrs][:created_at],
          :date_closed => pr[:attrs][:closed_at],
          :date_updated => pr[:attrs][:updated_at],
          :date_merged => pr[:attrs][:merged_at],
          :state => (pr[:attrs][:merged_at].nil? ? pr[:attrs][:state] : "merged")
          )
      end
    }
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
