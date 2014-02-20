require 'load_steps/load_step'
require 'octokit_utils'
require 'log_level'
require 'load_steps/load_helpers'
require 'constants'

class PreLoadStackalytics < LoadStep
  def name
    "Pre Load Stackalytics"
  end

  def execute(*args)
    puts "Start Step: #{name}"

    load_users_from_json
    create_stackalytics_companies

    puts "Finish Step: #{name}"    
  end

  def revert
  
  end


  def load_users_from_json
    # This function creates user records based on the stackalytics json file. 
    # To improve performance, this function should probably be executed before openstack repos are analyzed
    # These created records have no relation to github, need to fill in the blanks somehow?

    # Grab raw user mappings json from stackalytics website
    data = LoadHelpers.get_stackalytics_JSON

    # Create an array containing all company domains. If a user has multiple emails registered, we see if any of the
    # emails match with one of these company domains
    all_domains = []
    data["companies"].each { |company|
        all_domains += company["domains"]
    }
    all_domains.delete("")

    # Iterate through users
    data["users"].each { |user|
      company = nil
      email = nil

      # Register company if it doesn't exist in our db
      company = Company.find_by(name: user["companies"][0]["company_name"])
      if !company
        company = LoadHelpers.create_company_if_not_exist(user["companies"][0]["company_name"])
      end

      # Some users have multiple emails, try to make sure we get one that maps to a company domain
      user["emails"].each{ |e|
          email = e if all_domains.include?(e.split("@")[1])
      }

      # See if user is already stored in database
      u = User.find_by(email: email) || User.find_by(name: user["user_name"])

      # If so, update user's company
      if u
        u.company_id = company.id
        u.save
      # Otherwise, create record for user  
      else
        User.create(
            :company => company,
            :name    => user["user_name"],
            :email   => email ? email : user["emails"][-1] # Note that many users have multiple emails, will just store the first one for now
        )   
      end
    }
  end

  def create_stackalytics_companies
    # Grab raw user mappings json from stackalytics website
    data = LoadHelpers.get_stackalytics_JSON

    # Iterate through each company, create record if they don't exist.
    data["companies"].each { |company|
      LoadHelpers.create_company_if_not_exist(company["company_name"])
    }
  end
end