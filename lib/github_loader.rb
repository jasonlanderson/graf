require 'octokit_utils'
require 'log_level'

class GithubLoader

  @@current_load = nil

  ORG_NAME = "cloudfoundry"
  ORG_TO_COMPANY = {"vmware" => "VMware",
    "pivotal" => "Pivotal",
    "cloudfoundry" => "Pivotal",
    "pivotallabs" => "Pivotal",
    "Springsource" => "Pivotal",
    "pivotal-cf" => "Pivotal",
    "cfibmers" => "IBM"}
  REPOS_TO_SKIP = ["em-posix-spawn"]

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
    full_start = Time.now
    load_org_companies

    load_repos

    load_users
    
    load_all_prs # TODO: This should also load associated commits
    #load_prs_for_repo(Repo.find_by(name: "vmc"))
    
    com_start = Time.now
    load_all_commits
    current_load.log_msg("Total time to process commits is #{Time.now - com_start}", LogLevel::INFO)
    current_load.log_msg("Total time to process everything is #{Time.now - full_start}", LogLevel::INFO)
    #load_commits_for_repo(Repo.find_by(name: "vmc"))

    fix_users_without_companies
  end

  def self.delta_load(current_load)

    # Get last completed
    last_completed = GithubLoad.last_completed

    # TODO: Create delta load code

  end

  def self.load_org_companies()
    current_load.log_msg("***Loading Companies", LogLevel::INFO)
    ORG_TO_COMPANY.each { |org, company|
      create_company_if_not_exist(company, "org")
    }
  end

  def self.load_repos()
    current_load.log_msg("***Loading Repos", LogLevel::INFO)
  	client = OctokitUtils.get_octokit_client

    repos = client.organization_repositories(ORG_NAME)
    repos.each { |repo|
      unless REPOS_TO_SKIP.include?(repo[:attrs][:name])
      	Repo.create(:git_id => repo[:attrs][:id].to_i,
      		:name => repo[:attrs][:name],
      		:full_name => repo[:attrs][:full_name],
      		:fork => (repo[:attrs][:fork] == "true" ? true : false),
      		:date_created => repo[:attrs][:date_created],
      		:date_updated => repo[:attrs][:date_updated],
      		:date_pushed => repo[:attrs][:date_pushed]
      		)
      end
    }
  end

  def self.load_users()
    current_load.log_msg("***Loading Users", LogLevel::INFO)
    client = OctokitUtils.get_octokit_client
    start = Time.now           
    puts "Loading Users!"
    Repo.all().each {|repo|
      contributors = client.contributors(repo[:full_name])     
      contributors.each {|user| 
        unless User.find_by(login: user[:login]) 
          puts "Creating record for User #{user[:login]}"
          user_obj = client.user(user[:login]) 
          create_user_if_not_exist(user_obj)
          puts (Time.now - start)
        end  
      }
      collaborators = client.collaborators(repo[:full_name])     
      collaborators.each {|user| 
        unless User.find_by(login: user[:login]) 
          puts "Creating record for User #{user[:login]}"
          user_obj = client.user(user[:login]) 
          create_user_if_not_exist(user_obj)
          puts (Time.now - start)
        end  
      }
    }
  end

  def self.load_all_prs()
    current_load.log_msg("***Loading Pull Requests", LogLevel::INFO)
    Repo.all().each { |repo|
      load_prs_for_repo(repo)
    }
  end

  def self.load_all_commits()
    current_load.log_msg("***Loading Commits", LogLevel::INFO)
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
        :date_created => pr[:attrs][:created_at],
        :date_closed => pr[:attrs][:closed_at],
        :date_updated => pr[:attrs][:updated_at],
        :date_merged => pr[:attrs][:merged_at],
        :state => (pr[:attrs][:merged_at].nil? ? pr[:attrs][:state] : "merged")
        )
    }
  end

  def self.search_email(email)
      sleep(3.0)  
      search_results = OctokitUtils.search_users(email)
      num_results = search_results[:attrs][:total_count] 
      return search_results, num_results
  end
        
  def self.search_name(name)    
      sleep(3.0) # Throttling
      search_results = client.search_users("#{name} in:name", options = {:sort => "followers"}) # Grabs the most active/visual member with given name. 
      num_results = search_results[:attrs][:total_count]
      return search_results, num_results
  end    

  def self.load_commits_for_repo(repo)
    puts "---------"
    puts "--- Loading Commits for #{repo.full_name}"
    puts "---------"
    @@current_load.log_msg("Loading Commits for #{repo.full_name}", LogLevel::INFO)

    # Commits differ from pull requests. Each pull request has a github user profile associated with it. Commits on the other hand may either 

    # Preprocessing
    # First, use the "list_contributors" and the "list_collaborators" Octokit functions to populate our Users db. These get all Github users that have submitted at least one commit, as well as those that have been added as a "collaborator" by Pivotal.

    # Get commit object
    # Commit author is either a Github User object, or an "anonymous" contributor. If we get the Github User object, we have all the information we need about the user, but if not, we'll need to
    # 

    # Analyze commit submitter name to see whether commit was submitted by a pair (contains " and " or " & " or ", "), process names seperately if so  
    # For ex, take this commit that was submitted by both "Ryan Spore & Stephen Levine" here : https://github.com/cloudfoundry/vmc/commit/310fb38639eb0d3cc1ca645f4c45ca0da35c05aa

    # Check to see if commit submitter's name is already stored in our database. If so, load the user's object from the db, and associate user with commit.
    # If user isn't in database, search github db by email, and create user object from results.
    # If there are no results, search by name. If there are still no results, 

    # Case 1, "misspelled" name
    # For example, commits have been submitted by Maria Shaldibina under the names "Maria Shaldybina", "Maria Shalsybina", and "Mary Shaldybina"
    # Resolution: Create 

    # Case 2, searching github for name/email returns no results

    # Case 3, searching github for name returns multiple results
    # Sort results by activity

    # Case 4, name is 



    #Case

    processed = [] # Names that aren't registered in github
    client = OctokitUtils.get_octokit_client
    commits = client.commits(repo.full_name)
    start = Time.now           
    commits.each { |commit|
      #unless commit[:attrs][:commit][:attrs][:author][:name] == "Jenkins User"
      email = commit[:attrs][:commit][:attrs][:author][:email]

      # Create record of commit
      c = Commit.create(
          :repo_id => repo.id,
          #:user_id => user_id,
          :sha => commit[:sha], # Change sha to string
          :message => commit[:attrs][:commit][:attrs][:message],
          :date_created => commit[:attrs][:commit][:attrs][:author][:date]
        )

      names = commit[:attrs][:commit][:attrs][:author][:name].gsub(" and ", "|").gsub(", ","|").gsub(" & ", '|').split('|')
      # puts "________________"
      # puts commit[:attrs][:commit][:attrs][:author][:email]
      names.each do |name| 
        #puts name
        user = nil
        user_type = nil
        login = nil
        user_id = nil
        search_results = nil
        num_results = 0
        name = name.titleize
        # Remove initials becuase they don't work in search
        if ((name.split(' ').length > 2) && name.include?('.')) 
          name = "#{name.split(' ')[0]} #{name.split(' ')[2]}" 
        end
        
        # Check our db for user by checking: full name, first name, email
        user = (User.find_by(name: name) || User.find_by(login: name) || User.find_by(name: name.split(' ')[0]) || User.find_by(email: email))

        # If not, enter unless/if conditional
        # Search first, or Store based on email?
        # Lets choose store for the moment


        # Create record for user containing only name and  
        unless user
          if email.include?("pivotal")
            user = User.create(
              :company => Company.find_by(name: "Pivotal"), 
              :name => name
              ) 
          elsif email.include?("vmware") 
            user = User.create(
              :company => Company.find_by(name: "VMware"), 
              :name => name, 
              :email => email
              )  
          elsif email.include?("rbcon") 
            user = User.create(
              :company => Company.find_by(name: "Pivotal"), 
              :name => name
              )
          else
            # Search by email, unless commit has multiple contributors
            search_results, num_results = search_email(email) if !email.include?("pair")
            # Search by name if commit submitted by pair, or if email not in github db
            search_results, num_results = search_name(name) if ((!search_results || (search_results[:attrs][:total_count] == 0)) && (name.split(' ').length > 1))  
          
            if search_results && (num_results > 0)
              # puts "Creating record for user #{name}"
              # puts "WARNING: Search returned #{search_results[:attrs][:total_count]} results for #{name}, #{email}" if (num_results > 1)
              login = search_results[:attrs][:items][0][:attrs][:login]
              user_obj = client.user(login) 
              user = create_user_if_not_exist(user_obj) 
            else
              user = User.create(
                :name => name, 
                :email => email,
                :company => Company.find_by(name: "Independent") 
                )
            end
          end
        end

        c.users << user # Maps user to commit
        c.save()
      end
    }
  end


  def self.create_user_if_not_exist(pr_user)
    user_login = (pr_user[:attrs][:login] || pr_user[:attrs][:items][0][:attrs][:login])
    user = User.find_by(login: user_login) 
    #puts user_obj[:attrs][:login]
    #puts user_obj[:attrs][:items][0][:attrs][:login]
    unless user
      puts "---------"
      puts "--- Creating User: #{user_login}"
      puts "---------"
      @@current_load.log_msg("Creating User: #{user_login}", LogLevel::INFO)

      user_details = pr_user[:_rels][:self].get.data
      company_name = user_details[:attrs][:company]
      if ((company_name.nil?) or (company_name.downcase.include? "available") or (company_name.downcase.include? "independent") or (company_name.strip.length == 0) or company_name.nil?)
          company_name = "Independent"
      elsif (company_name.downcase.include? "vmware")
          company_name = "VMware"
      elsif ((company_name.downcase.include? "pivotal") || (company_name.downcase.include? "springsource")) 
          company_name = "Pivotal"
      elsif (company_name.downcase.include? "rbcon")
          company_name = "Rbcon"
      elsif (company_name.downcase.include? "ibm")
          company_name = "IBM"
      end

      company = nil
      if user_details[:attrs][:company] != "" && user_details[:attrs][:company] != nil
        company = create_company_if_not_exist(company_name, "user")
      else
        company = create_company_if_not_exist("Independent", "user")
      end

      name = "#{name.split(' ')[0]} #{name.split(' ')[2]}".titleize if (name && (name.split(' ').length > 2) && name.include?('.')) # Remove middle initial
      name = user_details[:attrs][:name].titleize if (user_details[:attrs][:name])
      
      user = User.create(
        :company => company,
        :git_id => user_details[:attrs][:id].to_i,
        :login => user_details[:attrs][:login],
        :name => name,
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
    current_load.log_msg("***Fixing Users Without Companies", LogLevel::INFO)
    client = OctokitUtils.get_octokit_client

    # For each organization
    ORG_TO_COMPANY.each { |org_name, company_name|
      company = Company.find_by(name: company_name, source: "org")

      orgMembers = client.organization_members(org_name)
      orgMembers.each { |member|
        user = User.find_by(login: member[:attrs][:login])
        if user && (!user.company || user.company == Company.find_by(name: "Independent"))
          @@current_load.log_msg("#{user} is in #{company}", LogLevel::INFO)
          user.company = company
          user.save
        end
      }
    }
  end
end