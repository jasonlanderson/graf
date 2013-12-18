require 'octokit_utils'

class GithubLoad

  ORG_NAME = "cloudfoundry"
  REPO_NAME = ORG_NAME + "/bosh"
  ORG_TO_COMPANY = Hash["vmware" => "VMware",
    "pivotal" => "Pivotal",
    "cloudfoundry" => "Pivotal",
    "pivotallabs" => "Pivotal",
    "Springsource" => "Pivotal",
    "cfibmers" => "IBM"]

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


  def self.create_user_if_not_exist(pr_user)

    user = User.find_by(login: pr_user[:attrs][:login])

    unless user
      puts "---------"
      puts "--- Creating User: #{pr_user[:attrs][:login]}"
      puts "---------"
      user_details = pr_user[:_rels][:self].get.data

      company = nil
      if user_details[:attrs][:company] != "" && user_details[:attrs][:company] != nil
        company = create_company_if_not_exist(user_details[:attrs][:company], "user")
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