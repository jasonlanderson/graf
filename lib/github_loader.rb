require 'octokit_utils'
require 'log_level'

class GithubLoader

  @@current_load = nil

  ORG_NAME = "cloudfoundry"
  ORG_TO_COMPANY = Hash["vmware" => "VMware",
    "pivotal" => "Pivotal",
    "cloudfoundry" => "Pivotal",
    "pivotallabs" => "Pivotal",
    "Springsource" => "Pivotal",
    "cfibmers" => "IBM"]

  def self.prep_github_load()
    if GithubLoad.all.length == 0
      initial_load = true
    else
      initial_load = false
    end

    current_load = GithubLoad.create(:load_start_time => Time.now,
      :load_complete_time => nil,
      :initial_load => initial_load
      )

    current_load.log_msg("Starting Load \##{current_load.id}...", LogLevel::INFO)
    current_load.log_msg("Any errors will be in Red", LogLevel::ERROR)
    current_load.log_msg("----------", LogLevel::INFO)

    return current_load
  end

  def self.finish_github_load(finished_load)
    # Log finished
    final_log_msg = finished_load.log_msg("Finished Load \##{finished_load.id}...", LogLevel::INFO)

    # Update database with completion time
    finished_load.load_complete_time = final_log_msg.log_date
    finished_load.save
  end

  def self.github_load(load = prep_github_load)
    @@current_load = load

    # Determine load type
    if load.initial_load
      # Initial load
      load.log_msg("***Doing an initial load", LogLevel::INFO)
      initial_load(load)
    else
      # Delta load
      load.log_msg("***Doing an delta load", LogLevel::INFO)
      delta_load(load)
    end

    finish_github_load(load)
  end

  def self.initial_load(current_load)
    # Do initial load
    current_load.log_msg("***Loading Companies", LogLevel::INFO)
    load_org_companies

    current_load.log_msg("***Loading Repos", LogLevel::INFO)
    load_repos

    current_load.log_msg("***Loading Pull Requests", LogLevel::INFO)
    load_all_prs
    #load_prs_for_repo(Repo.find_by(name: "bosh"))

    current_load.log_msg("***Fixing Users Without Companies", LogLevel::INFO)
    fix_users_without_companies
  end

  def self.delta_load(current_load)

    # Get last completed
    last_completed = GithubLoad.last_completed

    # TODO: Create delta load code

  end

  def self.load_org_companies()
    ORG_TO_COMPANY.each { |org, company|
      create_company_if_not_exist(company, "org")
    }
  end

  def self.load_repos()
  	client = OctokitUtils.get_octokit_client

    repos = client.organization_repositories(ORG_NAME)
    repos.each { |repo|
    	Repo.create(:git_id => repo[:attrs][:id].to_i,
    		:name => repo[:attrs][:name],
    		:full_name => repo[:attrs][:full_name],
    		:fork => (repo[:attrs][:fork] == "true" ? true : false),
    		:date_created => repo[:attrs][:date_created],
    		:date_updated => repo[:attrs][:date_updated],
    		:date_pushed => repo[:attrs][:date_pushed]
    		)
    }
  end


  def self.load_all_prs()
    Repo.all().each { |repo|
      load_prs_for_repo(repo)
    }
  end

  def self.load_prs_for_repo(repo)
    puts "---------"
    puts "--- Loading PRs for #{repo.full_name}"
    puts "---------"
    @@current_load.log_msg("Loading PRs for #{repo.full_name}", LogLevel::INFO)

  	client = OctokitUtils.get_octokit_client

    pull_requests = client.pulls(repo.full_name, state = "open")
    pull_requests.concat(client.pulls(repo.full_name, state = "closed"))
    pull_requests.each { |pr|

      # Get user and insert if doesn't already exist
      user = create_user_if_not_exist(pr[:attrs][:user])

      PullRequest.create(
        :repo_id => repo.id,
        :user_id => user.id,
        :git_id => pr[:attrs][:id].to_i,
        :pr_number => pr[:attrs][:number],
        :body => pr[:attrs][:body],
        :title => pr[:attrs][:title],
        :state => state,
        :date_created => pr[:attrs][:created_at],
        :date_closed => pr[:attrs][:closed_at],
        :date_updated => pr[:attrs][:updated_at],
        :date_merged => pr[:attrs][:merged_at]
        )
    }
  end


  def self.create_user_if_not_exist(pr_user)

    user = User.find_by(login: pr_user[:attrs][:login])

    unless user
      puts "---------"
      puts "--- Creating User: #{pr_user[:attrs][:login]}"
      puts "---------"
      @@current_load.log_msg("Creating User: #{pr_user[:attrs][:login]}", LogLevel::INFO)

      user_details = pr_user[:_rels][:self].get.data

      company = nil
      if user_details[:attrs][:company] != "" && user_details[:attrs][:company] != nil
        company = create_company_if_not_exist(user_details[:attrs][:company], "user")
      end
      if ((company[:name] == nil) || (company[:name].downcase.include? "available") || (company[:name].downcase.include? "independent") || (company[:name].strip == ""))
          company[:name] = "Independent"
        elsif (company[:name].downcase.include? "vmware")
          company[:name] = "VMware"
        elsif ((company[:name].downcase.include? "pivotal") || (company[:name].downcase.include? "springsource"))
          company[:name] = "Pivotal"
      end
      user = User.create(
        :company => company,
        :git_id => user_details[:attrs][:id].to_i,
        :login => user_details[:attrs][:login],
        :name => user_details[:attrs][:name],
        :location => user_details[:attrs][:location],
        :email => user_details[:attrs][:email],
        :date_created => user_details[:attrs][:created_at],
        :date_updated => user_details[:attrs][:updated_at]
        )
    end

    return user
  end

  def self.create_company_if_not_exist(company_name, src)
    company = Company.find_by(name: company_name, source: src)

    unless company
      puts "---------"
      puts "--- Creating Company: #{company_name}"
      puts "---------"
      @@current_load.log_msg("Creating Company: #{company_name}", LogLevel::INFO)

      company = Company.create(
        :name => company_name,
        :source => src
        )
    end

    return company
  end

  def self.fix_users_without_companies()
    client = OctokitUtils.get_octokit_client

    # For each organization
    ORG_TO_COMPANY.each { |org_name, company_name|
      company = Company.find_by(name: company_name, source: "org")

      orgMembers = client.organization(org_name)[:_rels][:members]
      orgMembers.get.data.each { |member|
        user = User.find_by(login: member[:attrs][:login])
        if user
          user.company = company
          user.save
        end
      }
    }
  end
end