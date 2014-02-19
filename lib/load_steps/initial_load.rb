require 'load_steps/load_step'
require 'load_steps/pre_load_known_companies'
require 'load_steps/pre_load_user_cache'
require 'load_steps/load_orgs'
require 'load_steps/post_fix_users_without_companies'
require 'load_steps/post_delete_companies_without_users'
require 'octokit_utils'
require 'log_level'

class InitialLoad < LoadStep

  def name
    "Initial Load"
  end

  def execute(*args)
    puts "Start Step: #{name}"

    # Pre-load
    (PreLoadKnownCompanies.new).execute
    #(PreLoadUserCache.new).execute

    # Load all orgs
    (LoadOrgs.new).execute

    # Post Load
    (PostFixUsersWithoutCompanies.new).execute
    (PostDeleteCompaniesWithoutUsers.new).execute

    puts "Finish Step: #{name}"    
  end

  def revert

  end
end