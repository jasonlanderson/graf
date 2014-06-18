require 'load_steps/load_step'
require 'octokit_utils'
require 'log_level'
require 'load_steps/load_helpers'
require 'constants'

class PreLoadUserCache < LoadStep
  def name
    "Pre Load User Cache"
  end

  def execute(*args)
    puts "Start Step: #{name}"

    # Load in JSON file
    json = File.read('db/user_cache.json')
    users = JSON.parse(json)

   users["users"].each { |u|
      GithubLoad.log_current_msg("Loading User From Cache: #{u['login'] || u['name']}", LogLevel::INFO)
      company = LoadHelpers.create_company_if_not_exist(u['company'])
      user = User.create(
        :company_id => company.id,
        :git_id => u["git_id"].to_i,
        :login => u["login"],
        :name => (u["name"] ? u["name"] : nil),
        :location => u["location"],
        :email => u["email"],
        :date_created => u["date_created"],
        :date_updated => u["date_updated"]
      )
    }

    GithubLoad.log_current_msg("Loaded #{User.all.to_a.length} users from json cache", LogLevel::INFO)

    puts "Finish Step: #{name}"    
  end

  def revert
  
  end
end