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
      User.where(login:  mapping['login']).update_all(company_id: company.id) if mapping['login'].length > 0
    end
  end

  def revert
  end
end
