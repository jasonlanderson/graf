require 'load_steps/pre_load_stackalytics'
require 'load_steps/pre_load_user_cache'
require 'load_steps/load_orgs'
require 'load_steps/post_fix_users_without_companies'
require 'load_steps/post_delete_companies_without_users'

class Constants

  LOAD_STEPS_INITIAL = [
    #PreLoadUserCache.new,
    #PreLoadStackalytics.new,
    LoadOrgs.new,
    PostFixUsersWithoutCompanies.new,
    PostDeleteCompaniesWithoutUsers.new
  ]

  LOAD_STEPS_REPO = [
    LoadRepoUsers.new,
    LoadRepoPullRequests.new,
    LoadRepoCommits.new
  ]

  @@settings = nil
  @@org_to_company_mapping = nil
  @@orgs = nil

  def self.get_settings
    if @@settings
      return @@settings
    end

    @@settings = JSON.parse(File.read('config/graf/settings.json'))
    return @@settings
  end

  def self.get_chart_colors
    get_settings["chart_colors"]
  end

  def self.get_org_to_company_mapping
    if @@org_to_company_mapping
      return @@org_to_company_mapping
    end

    @@org_to_company_mapping = JSON.parse(File.read('config/graf/org_to_company_mapping.json'))["mapping"]
    return @@org_to_company_mapping
  end

  def self.get_orgs
    if @@orgs
      return @@orgs
    end

    @@orgs = JSON.parse(File.read('config/graf/orgs.json'))["orgs"]
    return @@orgs
  end

end