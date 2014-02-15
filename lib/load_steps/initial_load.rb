require 'load_steps/load_step'
require 'load_steps/pre_load_known_companies'
require 'load_steps/pre_load_user_cache'
require 'load_steps/load_orgs'
require 'load_steps/post_fix_users_without_companies'
require 'octokit_utils'
require 'log_level'

class InitialLoad < LoadStep


  def name
    "Initial Load"
  end

  def execute(*args)
    puts "Start Step: #{name}"

    # Pre-load
    #(PreLoadSeedData.new).execute
    (PreLoadKnownCompanies.new).execute
    (PreLoadUserCache.new).execute

    # Load all orgs
    (LoadOrgs.new).execute

    # Post Load
    (PostFixUsersWithoutCompanies.new).execute
    #(PostDeleteCompaniesWithoutUsers.new).execute
    


    # load_org_companies

    # load_repos

    # load_users
    # load_all_prs # TODO: This should also load associated commits
    # #load_prs_for_repo(Repo.find_by(name: "vmc"))
    
    # #com_start = Time.now
    # load_all_commits
    # #current_load.log_msg("Total time to process commits is #{Time.now - com_start}", LogLevel::INFO)
    # #current_load.log_msg("Total time to process everything is #{Time.now - full_start}", LogLevel::INFO)
    # #load_commits_for_repo(Repo.find_by(name: "vmc"))

    # fix_users_without_companies




    puts "Finish Step: #{name}"    
  end

  def revert

  end
end