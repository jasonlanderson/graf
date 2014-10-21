require 'load_steps/load_helpers'
require 'load_steps/load_step'
require 'octokit_utils'
require 'log_level'
require 'constants'

class PostFixConvertUsersWithoutCompaniesToIndependent < LoadStep
  def name
    "Assign 'indepdent' as company to users without company"
  end

  def execute(*args)
    puts "Start Step: #{name}"

    GithubLoad.log_current_msg("***Assign 'indepdent' as company to users without company", LogLevel::INFO)
    null_company_id = Company.where(' name = "independent"').first.id
    puts "company with null name has id #{ null_company_id }"
    users_null_company = []
    users = User.find_by_sql('select login, name from  (SELECT c.name company_name, COUNT(*) num_prs, u.login login, u.name name  FROM pull_requests pr LEFT OUTER JOIN users u ON pr.user_id = u.id LEFT OUTER JOIN companies c ON u.company_id = c.id LEFT OUTER JOIN repos r ON pr.repo_id = r.id LEFT OUTER JOIN orgs o ON r.org_id = o.id  GROUP BY company_name, login  ) g where company_name is null  ORDER BY g.num_prs DESC;')
    users.each do | record |
      puts "user wth null company name: #{ record }"
      users_null_company.push(record.login)
    end
    
    User.where( :login => users_null_company ).update_all( :company_id => null_company_id ) if users_null_company.length > 0 && null_company_id
    GithubLoad.log_current_msg("Finish Step: #{name}", LogLevel::INFO)
  end

  def revert
  
  end
end
