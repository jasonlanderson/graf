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

    #@@current_load.log_msg("***Fixing Users Without Companies", LogLevel::INFO)
    client = OctokitUtils.get_octokit_client

    # For each organization
    Constants::ORG_TO_COMPANY.each { |org_name, company_name|
      company = Company.find_by(name: company_name, source: "org")
      orgMembers = client.organization_members(org_name)
      orgMembers.each { |member|
        user = User.find_by(login: member[:attrs][:login])
        if user && (!user.company || user.company == Company.find_by(name: "Independent"))
          #@@current_load.log_msg("#{user} is in #{company}", LogLevel::INFO)
          user.company = company
          user.save
        end
      }
    }

    puts "Finish Step: #{name}"    
  end

  def revert
  
  end
end