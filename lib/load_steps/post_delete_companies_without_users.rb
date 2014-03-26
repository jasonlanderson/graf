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
    # Mysql2::Error: Query execution was interrupted: SELECT `users`.* FROM `users`  WHERE ((NOT EXISTS (SELECT * FROM pull_requests where pull_requests.user_id = users.id)) AND (NOT EXISTS (SELECT * FROM commits_users where commits_users.user_id = users.id)) )
    Company.where("NOT EXISTS (SELECT * FROM users where companies.id = users.company_id)").destroy_all

    GithubLoad.log_current_msg("Finish Step: #{name}", LogLevel::INFO)  
  end

  def revert
  
  end
end