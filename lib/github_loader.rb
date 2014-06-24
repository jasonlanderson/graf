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

end