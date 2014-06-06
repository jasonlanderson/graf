require 'load_steps/load_step'
require 'octokit_utils'
require 'log_level'
require 'load_steps/load_helpers'
require 'constants'

class PostUpdateUserCache < LoadStep
  def name
    "Post Update User Cache"
  end

  def execute(*args)
    puts "Start Step: #{name}"

    GithubLoad.log_current_msg("Overriding User Cache", LogLevel::INFO)

    u_hash = {"users" => [] }

    User.all.to_a.each { |user|
      company_name = Company.find_by(id: user.company_id)
      u_hash["users"] << {
        "git_id" => user["git_id"],
        "login" => user["login"],
        "name" => user["name"] ? user["name"] : "",
        "location" => user["location"],
        "email" => user["email"],
        "date_created" => user["date_created"],
        "date_updated" => user["date_updated"],
        # All users should be linked to a company, conditional shouldn't be required
        # "company" => Company.find_by(id: user.company_id).name
        "company" => (company_name ? company_name.name : "Independent")
      }
    }
    File.open("db/test.json","w+") {|f| f.write(JSON.pretty_generate(u_hash)) }
    puts "Finish Step: #{name}"    
  end

  def revert
  
  end
end