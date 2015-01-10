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
              GithubLoad.log_current_msg("#{user} without clear company info is assigned to  #{company} as per org_to_company mapping", LogLevel::INFO)
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
    GithubLoad.log_current_msg("Finish Step: #{name}", LogLevel::INFO)
  end

  def revert
  
  end
end
