require 'load_steps/load_helpers'
require 'load_steps/load_step'
require 'octokit_utils'
require 'log_level'
require 'constants'

class PostFixUsersWithHiddenIdentity < LoadStep
  def name
    'Mediate records of users with hidden identitys'
  end

  def execute(*)
    # Iterate through each company
    Constants.mediation.each do |mapping|
      puts "assigning user #{mapping['login']} to company #{mapping['company']}"
      company = LoadHelpers.create_company_if_not_exist(mapping['company'])
      mapping['users'].each do | user |
        if user.length == 2
          puts "updating user #{ user['name'] }"
          User.where(login:  user['login']).update_all(company_id: company.id, name: user['name']) 
        else
          User.where(login:  user['login']).update_all(company_id: company.id) 
        end
      end
    end
  end

  def revert
  end
end
