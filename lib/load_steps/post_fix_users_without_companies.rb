require 'load_steps/load_helpers'
require 'load_steps/load_step'
require 'octokit_utils'
require 'log_level'
require 'constants'

class PostFixUsersWithoutCompanies < LoadStep
  def name
    "Fix Users Without Companies"
  end

  def execute(*args)
    puts "Start Step: #{name}"

    GithubLoad.log_current_msg("***Fixing Users Without Companies", LogLevel::INFO)
    client = OctokitUtils.get_octokit_client

    # Iterate through each company
    Constants.get_org_to_company_mapping.each { |mapping|
      company = Company.find_by(name: mapping['company'])

      # For each org which maps to this company
      mapping['orgs'].each { |org_name|
        begin
          orgMembers = LoadHelpers.github_organization_members(client, org_name)
          orgMembers.each { |member|
            user = User.find_by(login: member[:attrs][:login])
  
            # Only put in a company if they don't already have one
            if user && (!user.company || user.company == Company.find_by(name: "independent"))
              GithubLoad.log_current_msg("#{user} is in #{company}", LogLevel::INFO)
              user.company = company
              user.save
            end
          } if orgMembers
        rescue => e
          GithubLoad.log_current_msg("The following error occured with org_name being #{ org_name } when fixing users without companies ...", LogLevel::ERROR)
          GithubLoad.log_current_msg(e.message, LogLevel::ERROR)
          GithubLoad.log_current_msg(e.backtrace.join("\n"), LogLevel::ERROR)
        end
      }
    }
    users_null_company = []
    users = User.find_by_sql('select login, name from  (SELECT c.name company_name, COUNT(*) num_prs, u.login login, u.name name  FROM pull_requests pr LEFT OUTER JOIN users u ON pr.user_id = u.id LEFT OUTER JOIN companies c ON u.company_id = c.id LEFT OUTER JOIN repos r ON pr.repo_id = r.id LEFT OUTER JOIN orgs o ON r.org_id = o.id  GROUP BY company_name, login  ) g where company_name is null  ORDER BY g.num_prs DESC;')
    users.each do | record |
      puts "user wth null company name: #{ record }"
      user_null_company.push(record.login)
    end
    
    user_null_company.each do | login_id |
      user = User.find_by(login: login_id)
      user.company_id = 22
      user.save
    end
    GithubLoad.log_current_msg("Finish Step: #{name}", LogLevel::INFO)
  end

  def revert
  
  end
end
