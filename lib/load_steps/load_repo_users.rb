require 'load_steps/load_step'
require 'octokit_utils'
require 'log_level'
require 'load_steps/load_helpers'

class LoadRepoUsers < LoadStep

  def name
    "Load Repo Users"
  end

  def execute(*args)
    repo = args[0]
    puts "Start Step: #{name}"

    client = OctokitUtils.get_octokit_client
    pid, size = `ps ax -o pid,rss | grep -E "^[[:space:]]*#{$$}"`.strip.split.map(&:to_i)
    GithubLoad.log_current_msg("Initial memory #{size} KB", LogLevel::INFO)

    GithubLoad.log_current_msg("***Loading Users", LogLevel::INFO)
    
    # Contributors are those who have submitted at least one commit to the repo
    begin
      contributors = client.contributors(repo.full_name)        
    rescue => e
      GithubLoad.log_current_msg("The following error occured...", LogLevel::ERROR)
      GithubLoad.log_current_msg(e.message, LogLevel::ERROR)
      GithubLoad.log_current_msg(e.backtrace.join("\n"), LogLevel::ERROR)
      return nil
    end    
    if contributors     
      contributors.each {|user| 
        unless User.find_by(login: user[:login].downcase) 
          puts "Creating record for User #{user[:login]}"
          user_obj = client.user(user[:login]) 
          LoadHelpers.create_user_if_not_exist(user_obj)
        end  
      }
    end
    # Collaborators are those that have direct commit access
    collaborators = client.collaborators(repo.full_name)     
    if collaborators
      collaborators.each {|user| 
        unless User.find_by(login: user[:login].downcase) 
          puts "Creating record for User #{user[:login]}"
          user_obj = client.user(user[:login]) 
          LoadHelpers.create_user_if_not_exist(user_obj)
        end  
      }
    end
    pid, size = `ps ax -o pid,rss | grep -E "^[[:space:]]*#{$$}"`.strip.split.map(&:to_i)
    GithubLoad.log_current_msg("Memory before cleanup #{size} KB", LogLevel::INFO)    
    contributors = nil
    collaborators = nil
    GC.start
    pid, size = `ps ax -o pid,rss | grep -E "^[[:space:]]*#{$$}"`.strip.split.map(&:to_i)
    GithubLoad.log_current_msg("Memory after cleanup #{size} KB", LogLevel::INFO)
    
    puts "Finish Step: #{name}" 
  end

  def revert

  end
end
