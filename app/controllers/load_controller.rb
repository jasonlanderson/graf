require 'github_loader'
require 'log_level'

class LoadController < ApplicationController
  def load_status
    # Check to see what the status of the load is

    load_id = params[:load]
    load = GithubLoad.find(load_id)
    last_msg_id = params[:last_msg]

    # Get final messages
    messages = GithubLoadMsg.getMsgs(load_id, last_msg_id)

    # Populate completed field based on load

    
    render :json => "{\"completed\": \"#{load.load_complete_time ? 'true' : 'false'}\", \"messages\": #{messages.to_json}}"
  end

  def start_load
    # Create the load object
    github_load = GithubLoader.prep_github_load

    # TODO: Spawn new thread to do the actual load
    #GithubLoader.github_load
    
    render :text => "#{github_load.id}"
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

  # TODO Take this out
  def delete_load_history
    # Delete everything from the github_load table
    ActiveRecord::Base.connection.execute("DELETE FROM github_loads")

    # Delete everything from the github_load_msg table
    ActiveRecord::Base.connection.execute("DELETE FROM github_load_msgs")

    render :text => "Load History Deleted"
  end


  
end
