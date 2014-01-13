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

    current_load.log_msg("***Loading Commits", LogLevel::INFO)
    load_all_commits


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

  def self.load_all_commits()
    Repo.all().each { |repo|
      load_commits_for_repo(repo)
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
        :state => pr[:attrs][:state],
        :date_created => pr[:attrs][:created_at],
        :date_closed => pr[:attrs][:closed_at],
        :date_updated => pr[:attrs][:updated_at],
        :date_merged => pr[:attrs][:merged_at]
        )
    }
  end

  def self.load_commits_for_repo(repo)
    puts "---------"
    puts "--- Loading Commits for #{repo.full_name}"
    puts "---------"
    @@current_load.log_msg("Loading Commits for #{repo.full_name}", LogLevel::INFO)

    client = OctokitUtils.get_octokit_client
    commits = client.commits(repo.full_name)
    commits.each { |commit|

    unless commit[:attrs][:commit][:attrs][:author][:name] == "Jenkins User"
        
      # This does not work if commit pushed by "Jenkins User"
      # How do we avoid hitting the search API limit?
      names = commit[:attrs][:commit][:attrs][:author][:name].gsub(" and ", "|").gsub(", ","|").gsub(" & ", '|').split('|')
      puts commit[:attrs][:commit][:attrs][:author][:email]
      names.each do |name| 
        #print name.to_s + " "
        search_results = nil
        if User.find_by(name: name)
          login = User.find_by(name: name)[:login] # See if user table has matching record
          user_id = User.find_by(name: name)[:id]         
        end
        #name = User.find_by(name: name)[:name] 

        unless login && user_id
          search_results = client.search_users(name) # If not, search for user object. 
          #if (search_results[:attrs][:total_count] > 0))
          ((search_results[:attrs][:total_count]) && (search_results[:attrs][:total_count] > 0)) ? nil : break # If this if false, name is incorrectly spelled / has no associated profile
          login = search_results[:attrs][:items][0][:attrs][:login]
          user_obj = client.user(login)
          user = create_user_if_not_exist(user_obj) 
        end
        
        Commit.create(
          :repo_id => repo.id,
          :user_id => user_id,
          :sha => commit[:sha], # Change sha to string
          :message => commit[:attrs][:commit][:attrs][:message],
          :date_created => commit[:attrs][:commit][:attrs][:author][:date]
        )
        
        #puts User.find_by(name: name) #? nil : next
        #login = client.search_users(commit[:attrs][:commit][:attrs][:author][:name])[:attrs][:items][0][:attrs][:login]
        #user_obj = client.user(login)
      end
    #client.search_users()
    end
    }

  end


  def self.create_user_if_not_exist(pr_user)
    user_login = (pr_user[:attrs][:login] || pr_user[:attrs][:items][0][:attrs][:login])
    puts user_login
    user = User.find_by(login: user_login) 
#    puts user_obj[:attrs][:login]
#    puts user_obj[:attrs][:items][0][:attrs][:login]
    unless user
      puts "---------"
      puts "--- Creating User: #{user_login}"
      puts "---------"
      @@current_load.log_msg("Creating User: #{user_login}", LogLevel::INFO)

      user_details = pr_user[:_rels][:self].get.data

      company_name = user_details[:attrs][:company]

      if ((company_name.nil?) or (company_name.downcase.include? "available") or (company_name.downcase.include? "independent") or (company_name.strip == ""))
          company_name = "Independent"
      elsif (company_name.downcase.include? "vmware")
          company_name = "VMware"
      elsif ((company_name.downcase.include? "pivotal") || (company_name.downcase.include? "springsource")) 
          company_name = "Pivotal"
      end

      company = nil
      if user_details[:attrs][:company] != "" && user_details[:attrs][:company] != nil
        company = create_company_if_not_exist(company_name, "user")
      else
        company = create_company_if_not_exist("Independent", "user")
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