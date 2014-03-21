require "spec_helper"
require "load_steps/load_helpers"
require 'faker'

describe LoadHelpers do
  #name = "Kalonji K. bankole"
  #it 'contains no initial?' do
  # expect(LoadHelpers.format_name(name)).to equal("Kalonji Bankole")
  #end
  #
  #name = "kalonji BANKOLE"
  #it 'capitalized?' do
  # expect LoadHelpers.format_name(name).to equal "Kalonji Bankole"
  #end

  class OctokitUtils
    def self.get_octokit_client()
        return @@_client unless @@_client == nil
        @@_client = Client.new
        return @@_client

    end

    def self.get_rate_limit()
      return 5000
    end

    def self.search_users(email)
      # This actually shouldn't be used
      # Should also change method name
      search_results = get_octokit_client.search_users(email) # Should only search by email if email doesn't include the word "pair"
      return search_results
    end

  end

  class Client

    all_ids = []
    def self.get_unique_id
        # Easier option would be to delete Objects with duplicate git_ids
        id = rand(1000..99999) 
        # Line below checks to see if random git_id is in use by any other mock objects
        # if User.find_by(id: id) || PullRequest.find_by(id: id) ...         
    end

    def self.search_users
      # What should we do here? This is used for committers that aren't linked to a id
    end



    def create_fake_users(count)
      for i in 1..count
        # Use random number to determine if user is Independent or not
        if rand(10) < 5
          company = Company.find_by(name: "Independent")
        else  
          company = LoadHelpers.create_company_if_not_exist(Faker::Company.name)
        end

        # Create user with fake data
        user = User.create(
          :company => company,
          :git_id => rand(100..9999),
          :login => Faker::Internet.user_name,
          :name => Faker::Name.name,
          #:location => , 
          :email => Faker::Internet.email,
          :created_at => rand(2.years).ago
        )
      end
    end

    def get

    end

    def self.create_user
      u = Hash.new
      s = Struct(:get)
      d = Struct(:)
      #g = get.new(data)
      u[:_rels] = {
          :self => {
            get => {
              data => {
                :attrs => {
                  :company => "IBM",
                  :login => "kkbankol",
                  :name => "Kalonji Bankole"
                }
              }
            }
          }
        }
        return u
    end


    def self.create_pull(repo)
      p = {}
      p[:attrs] = { 
          :repo_id => 1,
          :id => 1,
          :number => 1, 
          :state => "closed", 
          :title => "Test",
          :user => "User",
          :body => "Body",
          :created_at => Time.now,
          :updated_at => Time.now
      }

      return p
    end


    def self.create_commit(repo)
      repo = nil
      length = 40
      c = Hash.new
      c = {
            :attrs => {
              :login => "username",  
              :repo_id => 1,
              :sha => rand(36**length).to_s(36),
              :message => "blah blah blah",
              :date_created => Time.now,
              :commit => {
                :attrs => {
                  :author => {
                    :email => "user@company.com",
                    :name => "name"
                  }
                }
              }
            }
          }
      return c
    end

    def self.pulls(repo_name, state)
      pulls = []
      num_pulls = rand(20..100)
      for i in 1..num_pulls
        pulls << pull
      end
      return pulls
    end

    def self.commits(repo_name)
      commits = []
      for i in 1..20
        commits << create_commit("repo")
      end
      return commits
    end

    def self.orgs(owner)

    end

    def self.organization_repositories(org)
    
    end

    def self.contributors(repo)
    
    end

    def self.collaborators(repo)
    
    end

    def self.organization_members(org)
    
    end

    def self.user(login)
      return
    end

  end

  # self.merge
  it 'merges similar companies' do
     # This merge function should be more generic by removing "Corporation", ".Inc", etc
     company = "IBM Corporation"
     expect(LoadHelpers.merge(company)).to match("IBM")
  end

  # self.create_user_if_not_exist

    # Test returns user object that already exists
    # pr_user = User.all[0] #client.user("kkbankol")


    # Test creates user object that doesn't exist
    # name = "some user not in db"
    # pr_user = client.user(name)
    # LoadHelpers.create_user_if_not_exist(pr_user)
    # 

    # Test associating company with a user (should become method)



  # it 'searching commit author'
  #   name = "Kalonji Bankole"
  #   LoadHelpers.search_name()
  #   name = "Matthew"

  # end


  # Test that there are no users without a company. Those users should be under "Independent"
  it 'all users have a company' do
    # Create 20 to 100 mock users
    user_count = rand(20..100)
    create_fake_users(user_count)
    users = User.all

    # Remove the company_id field from 15 random users
    for i in 1..(15)
      User.find_by(id: rand(user_count)).company_id = nil
    end

    User.where(company_id: nil)

    expect(User.where(company_id: nil).length).to match(0)
    User.destroy_all
  end

  # Test that there are no companies without users
  it 'all companies have users' do
    #Load mock objects      
        

    # Branch out, show results in both cases. What are the results when the where statement is true, and vice versa

    #Run 
    expect(Company.where("NOT EXISTS (SELECT * FROM users where companies.id = users.company_id)").length).to match(0)
  end
end