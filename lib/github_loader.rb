require 'octokit_utils'
require 'log_level'
require 'load_steps/initial_load'
require 'load_steps/delta_load'
require 'load_steps/load_helpers'


class GithubLoader

  def self.prep_github_load()
    if GithubLoad.all.length == 0
      initial_load = true
    else
      initial_load = false
    end

    current_load = GithubLoad.create(:load_start_time => Time.now,
      :load_complete_time => nil,
      :initial_load => initial_load
      )

    current_load.log_msg("Starting Load \##{current_load.id}...", LogLevel::INFO)
    current_load.log_msg("Any errors will be in Red", LogLevel::ERROR)
    current_load.log_msg("----------", LogLevel::INFO)

    return current_load
  end

  def self.finish_github_load(finished_load)
    # Log finished
    final_log_msg = finished_load.log_msg("Finished Load \##{finished_load.id}...", LogLevel::INFO)

    # Update database with completion time
    finished_load.load_complete_time = final_log_msg.log_date
    finished_load.save
  end

  def self.github_load(load = prep_github_load)
    # Set the current load so that the rest of the load process can log
    GithubLoad.set_current_load(load)

    # Determine load type
    if load.initial_load
      # Initial load
      load.log_msg("***Doing an initial load", LogLevel::INFO)
      begin
        (InitialLoad.new).execute
      # Catch all exceptions, even out of memory exceptions
      # Otherwise just get rid of Exception below
      rescue Exception => e
        load.log_msg("The following error occured...", LogLevel::ERROR)
        load.log_msg(e.message, LogLevel::ERROR)
        load.log_msg(e.backtrace.join("\n"), LogLevel::ERROR)

        # Reraise the exception to pass it on
        raise
      end
      
    else
      # Delta load
      load.log_msg("***Doing an delta load", LogLevel::INFO)
      begin
        #GithubLoader.delta_load(load)
        (DeltaLoad.new).execute
      rescue Exception => e
        load.log_msg("The following error occured...", LogLevel::ERROR)
        load.log_msg(e.message, LogLevel::ERROR)
        load.log_msg(e.backtrace.join("\n"), LogLevel::ERROR)

        # Reraise the exception to pass it on
        raise
      end
    end

    finish_github_load(load)
  end

  def self.get_state(repo, number)
    client = OctokitUtils.get_octokit_client
    pr = client.pull(repo, number)
    return pr[:date_merged]
  end

  # def self.delta_load(current_load)
  #   # Get last completed
  #   puts "Begin Delta load"
  #   #last_completed = Time.new("2014", "01").utc # GithubLoad.last_completed
  #   last_completed = GithubLoad.last_completed[:load_complete_time]
  #   parsed_date = "#{last_completed.year}-#{last_completed.month}-#{last_completed.day}"
  #   client = OctokitUtils.get_octokit_client
  #   # TODO: Create delta load code

  #   Repo.all().each {|repo|
  #       # Load PRs for each repo
  #       pulls = JSON.parse(HTTParty.get("https://api.github.com/search/issues?q=repo:#{repo[:full_name]}+type:pr+updated:%3E#{parsed_date}", :headers => {"User-Agent" => "kkbankol"} ).body)["items"]
  #       #pulls = client.pulls(repo[:full_name], "closed") + client.pulls(repo[:full_name], "open") # Doesn't seem to pick up "If-Modified-Since" error
  #       if pulls
  #       pulls.each { |p|
  #           pull = p.with_indifferent_access
  #           user = nil
  #           record = nil

  #           # Check to see if given PR is already in our DB.
  #           record = PullRequest.find_by(git_id: pull[:id].to_i)
  #           date_merged = client.pull(repo.full_name, pull[:number])[:date_merged]

  #           # If we have a record of current pull request already, update all dynamic fields
  #           if record #and (last_completed < pull[:updated_at]) 
  #             puts "Updating PR #{pull[:number]} from #{repo[:full_name]}"
  #             record.state = (date_merged.nil? ? pull[:state] : "merged")
  #             record.date_merged = date_merged
  #             record.date_updated = Time.now.utc #
  #             record.date_closed = pull[:date_closed] 
  #             record.save
  #             # Are there any other fields that may change?

  #           # If the PR is new, and not in our DB, create a record for it
  #           elsif !record
  #             puts "Creating PR #{pull[:number]} from #{repo[:full_name]}"
  #             user = LoadHelpers.create_user_if_not_exist(pull[:user])
  #             PullRequest.create(
  #               :repo_id => repo.id,
  #               :user_id => user.id,
  #               :git_id => pull[:id].to_i,
  #               :pr_number => pull[:number],
  #               :body => pull[:body],
  #               :title => pull[:title],
  #               :date_created => pull[:created_at],
  #               :date_closed => pull[:closed_at],
  #               :date_updated => Time.now.utc,
  #               :date_merged => date_merged,
  #               :state => (date_merged.nil? ? pull[:state] : "merged")
  #             )
  #           end
  #       }
  #       end
        
  #       commits = client.commits(repo[:full_name], :since => parsed_date)
  #       if commits
  #       commits.each { |commit|
  #           record = nil
  #           record = Commit.find_by(sha: commit[:sha])
  #           if record #and (last_completed < pull[:updated_at]) 
  #                 record.message = commit[:message] 
  #                 record.save                
  #           elsif !record
  #                 email = commit[:attrs][:commit][:attrs][:author][:email]
  #                 # Create record of commit
  #                 c = Commit.create(
  #                     :repo_id => repo.id,
  #                     :sha => commit[:sha], # Change sha to string
  #                     :message => commit[:attrs][:commit][:attrs][:message],
  #                     :date_created => commit[:attrs][:commit][:attrs][:author][:date]
  #                   )

  #                 names = commit[:attrs][:commit][:attrs][:author][:name].gsub(" and ", "|").gsub(", ","|").gsub(" & ", '|').split('|')
  #                 LoadHelpers.process_authors(c, email, names)
  #           end
  #       }
  #       end   
  #   }
  #   last_completed = Time.now.utc
  # end

end