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
    #raise ArgumentError, "Too many arguments" if args.length > 2
    #var = args[0]
    puts "Start Step: #{name}"

    #@@current_load.log_msg("***Loading Companies", LogLevel::INFO)
    Constants::ORG_TO_COMPANY.each { |org, company|
      LoadHelpers.create_company_if_not_exist(company, "org")
    }

    puts "Finish Step: #{name}"    
  end

  def revert
  
  end
end