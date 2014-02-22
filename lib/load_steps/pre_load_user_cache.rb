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

    users.each_with_index { |u, index|
      next if index == 0
      company = LoadHelpers.create_company_if_not_exist(company)

      user = User.create(
        :company_id => company.id,
        :git_id => u["git_id"].to_i,
        :login => u["login"],
        :name => u["name"],
        :location => u["location"],
        :email => u["email"],
        :date_created => u["date_created"],
        :date_updated => u["date_updated"]
      )
    }

    puts "Finish Step: #{name}"    
  end

  def revert
  
  end
end