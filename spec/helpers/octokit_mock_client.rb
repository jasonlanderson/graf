class OctokitMockClient
  def self.get_unique_id
      # Easier option would be to delete Objects with duplicate git_ids
      id = rand(1000..99999) 
      # Line below checks to see if random git_id is in use by any other mock objects
      # if User.find_by(id: id) || PullRequest.find_by(id: id) ...         
  end

  def self.search_users
    # What should we do here? This is used for committers that aren't linked to a id
  end



  # def create_fake_users(count)
  #   for i in 1..count
  #     # Use random number to determine if user is Independent or not
  #     if rand(10) < 5
  #       company = Company.find_by(name: "Independent")
  #     else  
  #       company = LoadHelpers.create_company_if_not_exist(Faker::Company.name)
  #     end

  #     # Create user with fake data
  #     user = User.create(
  #       :company => company,
  #       :git_id => rand(100..9999),
  #       :login => Faker::Internet.user_name,
  #       :name => Faker::Name.name,
  #       #:location => , 
  #       :email => Faker::Internet.email,
  #       :created_at => rand(2.years).ago
  #     )
  #   end
  # end

  def self.create_user
    u = [
    # client.user result
    {
          :_rels => {
            :self => Struct.new(:get).new(Struct.new(:data).new({:attrs => {
            :company => "IBM",
            :login => "kkbankol",
            :name => "Kalonji Bankole"
            }}))          
      }
    },

    {
          :_rels => {
            :self => Struct.new(:get).new(Struct.new(:data).new({:attrs => {
            :company => "Stark and Wayne",
            :login => "drnic",
            :name => "Dr. Nic Williams"
            }}))          
      }
    },

    {
          :_rels => {
            :self => Struct.new(:get).new(Struct.new(:data).new({:attrs => {
            :company => "IBM",
            :login => "kkbankol",
            :name => "Kalonji Bankole"
            }}))          
      }
    },

    {
          :_rels => {
            :self => Struct.new(:get).new(Struct.new(:data).new({:attrs => {
            :company => "IBM",
            :login => "kkbankol",
            :name => "Kalonji Bankole"
            }}))          
      }
    }
  ]
    return u
  end

  def get_users(num)
    users = []
    for i in 1..num
      users << create_user
    end
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
            :message => "message",
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

  def pulls(repo_name, state)
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

  def self.organization_repositories(org)
    
  end

  def self.contributors(num)
    num_pulls = rand(20..100)
    contributors = []
    for i in 1..num_pulls
      contributors << create_user
    end
    return contributors
  end

  def self.collaborators(num)
    num_pulls = rand(20..100)
    contributors = []
    for i in 1..num_pulls
      contributors << create_user
    end
    return contributors    
  end

  def self.organization_members(num)
    num_pulls = rand(20..100)
    contributors = []
    for i in 1..num_pulls
      contributors << create_user
    end
    return contributors
  end

  def self.user(login)
    return
  end

end