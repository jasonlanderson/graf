module Constants
  CHART_COLORS = ['#B82E2E', '#2EB82E', '#C75000', '#6629A3', '#2966A3', '#649ED8'];

  #ORG_NAMES = ["cloudfoundry", "cloudfoundry-attic", "cloudfoundry-incubator"]
  ORG_NAMES = ["cloudfoundry", "cloudfoundry-incubator"]

  # Rackspace, VMware,
  REPOS_TO_SKIP = ["em-posix-spawn"]

  ORG_TO_COMPANY = {"vmware" => "VMware",
    "pivotal" => "Pivotal",
    "cloudfoundry" => "Pivotal",
    "pivotallabs" => "Pivotal",
    "Springsource" => "Pivotal",
    "pivotal-cf" => "Pivotal",
    "cfibmers" => "IBM"}

  
end