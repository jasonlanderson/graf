require 'load_steps/load_step'
require 'octokit_utils'
require 'log_level'
require 'constants'

class PostDeleteCompaniesWithoutUsers < LoadStep
  def name
    "Post Delete Companies Without Users"
  end

  def execute(*args)
    puts "Start Step: #{name}"

    Company.where("NOT EXISTS (SELECT * FROM users where companies.id = users.company_id)").destroy_all

    GithubLoad.log_current_msg("Finish Step: #{name}", LogLevel::INFO)  
  end

  def revert
  
  end
end