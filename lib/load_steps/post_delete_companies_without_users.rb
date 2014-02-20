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

    companies = Company.where("NOT EXISTS (SELECT * FROM users where companies.id = users.company_id)")


    puts "Finish Step: #{name}"    
  end

  def revert
  
  end
end