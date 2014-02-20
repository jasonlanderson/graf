require 'load_steps/pre_load_stackalytics'
require 'load_steps/pre_load_user_cache'
require 'load_steps/load_orgs'
require 'load_steps/post_fix_users_without_companies'
require 'load_steps/post_delete_companies_without_users'

module Constants

  LOAD_STEPS_INITIAL = [
      #PreLoadUserCache.new,
      PreLoadStackalytics.new,
      LoadOrgs.new,
      PostFixUsersWithoutCompanies.new,
      PostDeleteCompaniesWithoutUsers.new
    ]

  LOAD_STEPS_REPO = [
      LoadRepoUsers.new,
      LoadRepoPullRequests.new,
      LoadRepoCommits.new
    ]

  CHART_COLORS = ['#B82E2E', '#2EB82E', '#C75000', '#6629A3', '#2966A3', '#649ED8'];

  #ORG_NAMES = [ "cloudfoundry-incubator" ] #["openstack", "openstack-infra", "cloudfoundry", "cloudfoundry-incubator", "cloudfoundry-community", "cloudfoundry-attic", "mongodb"]
  ORG_NAMES = [ "cloudfoundry-incubator", "openstack", "openstack-infra", "cloudfoundry", "cloudfoundry-incubator", "cloudfoundry-community", "cloudfoundry-attic", "mongodb"]


  # rackspace, vmware, foursquare, 10gen, lift, mongodb, jenkinsci, github
  REPOS_TO_SKIP = ["em-posix-spawn"]

  ORG_TO_COMPANY = {"vmware" => "VMware",
    "pivotal" => "Pivotal",
    "cloudfoundry" => "Pivotal",
    "pivotallabs" => "Pivotal",
    "Springsource" => "Pivotal",
    "pivotal-cf" => "Pivotal",
    "cfibmers" => "IBM",
    "rackspace" => "Rackspace",
    "foursquare" => "Foursquare",
    "10gen" => "MongoDB",
    "lift" => "Lift",
    "mongodb" => "MongoDB",
    "jenkinsci" => "Jenkins",
    "github" => "Github",
    "rackerlabs" => "Rackspace",
    "racker" => "Rackspace"
  }
  
end