require 'load_steps/load_step'
require 'octokit_utils'
require 'log_level'
require 'load_steps/load_helpers'
require 'constants'

class PreLoadKnownCompanies < LoadStep
  def name
    "Pre Load Known Companies"
  end

  def execute(*args)
    puts "Start Step: #{name}"

    GithubLoad.log_current_msg("***Loading Companies", LogLevel::INFO)
    Constants::ORG_TO_COMPANY.each { |org, company|
      LoadHelpers.create_company_if_not_exist(company)
    }

    # LoadHelpers.load_users_from_json
    # LoadHelpers.create_stackalytics_companies

    puts "Finish Step: #{name}"    
  end

  def revert
  
  end
end