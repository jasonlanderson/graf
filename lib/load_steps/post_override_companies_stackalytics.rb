require 'load_steps/load_step'
require 'load_steps/load_helpers'
require 'octokit_utils'
require 'log_level'
require 'constants'

class PostOverrideCompaniesStackalytics < LoadStep
  def name
    "Post Override Companies Stackalytics"
  end

  def execute(*args)
    puts "Start Step: #{name}"

    override_user_companies

    puts "Finish Step: #{name}"
  end

  def revert
  
  end

  def override_user_companies
    # This function overrides a user's listed company if the user domain matches one of the companies associated domains

    # Grab raw user mappings json from stackalytics website
    data = LoadHelpers.get_stackalytics_JSON

    # Each company has a set of domains associated with it. Here, we'll iterate through each domain, and user records 
    # that have a identical domain to the same company 
    data["companies"].each { |company|
      company["domains"].each { |domain|
          users = User.where("email like ?", "%#{domain}%")
          match = Company.find_by(name: company["company_name"])
          users.each { |user|
              if !user.company_id || user.company_id == '22' # If user has no affiliated company or is independent
                  user.company_id = match.id
                  user.save
              end
          }
      }
    } 
  end
end