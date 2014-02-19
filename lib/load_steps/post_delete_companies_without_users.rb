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

    puts "TODO: Implement Post Delete Companies Without Users"
    #select c.name, count(*)  as mycount from users u  RIGHT OUTER JOIN companies c ON  u.company_id = c.id group by c.name 

    puts "Finish Step: #{name}"    
  end

  def revert
  
  end
end