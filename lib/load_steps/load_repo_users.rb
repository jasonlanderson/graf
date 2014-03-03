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
    GithubLoad.log_current_msg("***Loading Users", LogLevel::INFO)
    
    # Look through the contributors first
    contributors = client.contributors(repo.full_name)     
    contributors.each {|user| 
      unless User.find_by(login: user[:login].downcase) 
        puts "Creating record for User #{user[:login]}"
        puts user.inspect
        user_obj = client.user(user[:login]) 
        LoadHelpers.create_user_if_not_exist(user_obj)
      end  
    }

    # Look through the collaborators second
    collaborators = client.collaborators(repo.full_name)     
    collaborators.each {|user| 
      unless User.find_by(login: user[:login].downcase) 
        puts "Creating record for User #{user[:login]}"
        user_obj = client.user(user[:login]) 
        LoadHelpers.create_user_if_not_exist(user_obj)
      end  
    }

    puts "Finish Step: #{name}" 
  end

  def revert

  end
end