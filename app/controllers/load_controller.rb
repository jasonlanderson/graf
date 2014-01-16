require 'github_loader'
require 'log_level'

class LoadController < ApplicationController
  def load_status
    # Check to see what the status of the load is
    load_id = params[:load]
    load = GithubLoad.find(load_id)
    last_msg_id = params[:last_msg]

    # Get messages since we last checked
    messages = GithubLoadMsg.getMsgs(load_id, last_msg_id)

    # Populate completed field based on load
    completed = load.load_complete_time ? 'true' : 'false'
    
    # Send back the JSON object
    render :json => "{\"completed\": \"#{completed}\", \"messages\": #{messages.to_json}}"
  end

  def start_load
    # Create the load object
    load = GithubLoader.prep_github_load

    # Spawn new thread to do the actual load
    Thread.new do
      GithubLoader.github_load(load)

      # Close thread's DB connection
      ActiveRecord::Base.connection.close
    end

    render :text => "#{load.id}"
  end

  def index
    @github_loads = GithubLoad.all

    # Is there a running load?
    @running_load = nil
    last_load = @github_loads.last
    if last_load && last_load.load_complete_time == nil
      @running_load = last_load
      @running_msgs = GithubLoadMsg.getMsgs(@running_load.id)
    end

    @error_log_level = LogLevel::ERROR
  end

  # TODO Take this out after development
  def delete_load_history
    GithubLoad.delete_all
    GithubLoadMsg.delete_all

    render :text => "Load History Deleted"
  end

  # TODO Take this out after development
  def delete_all_data
    Commit.delete_all
    Company.delete_all
    GithubLoadMsg.delete_all
    GithubLoad.delete_all
    PullRequest.delete_all
    Repo.delete_all
    User.delete_all

    render :text => "All Data Deleted"
  end
  
end
