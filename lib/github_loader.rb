require 'octokit_utils'
require 'log_level'
require 'load_steps/initial_load'

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
      (InitialLoad.new).execute
    else
      # Delta load
      load.log_msg("***Doing an delta load", LogLevel::INFO)
      #(DeltaLoad.new).execute
    end

    finish_github_load(load)
  end

  #def self.delta_load(current_load)
    # # Get last completed
    # puts "Begin Delta load"
    # last_completed = Time.new("2014", "01").utc # GithubLoad.last_completed
    # client = OctokitUtils.get_octokit_client
    # # TODO: Create delta load code


    # Repo.all().each {|repo|
    #     # Load PRs for each repo
    #     pulls = client.pulls(repo[:full_name], "closed") + client.pulls(repo[:full_name], "open") # Doesn't seem to pick up "If-Modified-Since" error
    #     pulls.each { |pull|
    #         user = nil
    #         record = nil

    #         # Check to see if given PR is already in our DB.
    #         record = PullRequest.find_by(git_id: pull[:id])

    #         # If we have a record of current pull request already, update all dynamic fields
    #         if record and (last_completed < pull[:updated_at]) 
    #           puts "Updating PR #{pull[:number]} from #{repo[:full_name]}"
    #           record.state = pull[:state]
    #           record.date_merged = pull[:date_merged]
    #           record.date_updated = Time.now.utc #
    #           record.date_closed = pull[:date_closed] 
    #           # Are there any other fields that may change?
    #           record.save

    #         # If the PR is new, and not in our DB, create a record for it
    #         elsif !record
    #           puts "Creating PR #{pull[:number]} from #{repo[:full_name]}"
    #           user = create_user_if_not_exist(pr[:attrs][:user])
    #           PullRequest.create(
    #             :repo_id => repo.id,
    #             :user_id => user.id,
    #             :git_id => pr[:attrs][:id].to_i,
    #             :pr_number => pr[:attrs][:number],
    #             :body => pr[:attrs][:body],
    #             :title => pr[:attrs][:title],
    #             :date_created => pr[:attrs][:created_at],
    #             :date_closed => pr[:attrs][:closed_at],
    #             :date_updated => Time.now.utc,
    #             :date_merged => pr[:attrs][:merged_at],
    #             :state => (pr[:attrs][:merged_at].nil? ? pr[:attrs][:state] : "merged"),
    #             :org => repo.org
    #           )
    #         end
    #     }

    #     commits = client.commits(repo[:full_name]) #, {:headers => { "If-Modified-Since" => "Sun, 05 Jan 2014 15:31:30 GMT" }) # => last_modified
    #     commits.each { |commit|
    #         record = nil
    #         record = Commit.find_by(sha: commit[:sha])
    #         if record and (last_completed < pull[:updated_at]) 
    #               record.message = commit[:message] 
    #               record.save                
    #         elsif !record
    #               email = commit[:attrs][:commit][:attrs][:author][:email]
    #               # Create record of commit
    #               c = Commit.create(
    #                   :repo_id => repo.id,
    #                   :sha => commit[:sha], # Change sha to string
    #                   :message => commit[:attrs][:commit][:attrs][:message],
    #                   :date_created => commit[:attrs][:commit][:attrs][:author][:date]
    #                 )

    #               names = commit[:attrs][:commit][:attrs][:author][:name].gsub(" and ", "|").gsub(", ","|").gsub(" & ", '|').split('|')
    #               process_authors(c, email, names)

    #         end

    #     }
        
    # }
  #end
end