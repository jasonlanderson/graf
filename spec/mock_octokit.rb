class MockOctokit


  def search_users(user_name, options = {})
    if (user_name == "Kalonji Bankole in:name") 
      return {:total_count => 1, 
              :items => 
                [
                  {:attrs =>
                    {:login => "kkbankol", 
                     :name => "Kalonji Bankole"
                    }        
                  } 
                ]
             }
    else
      return {:total_count => 0, :items => []}
    end
    # What should we do here? This is used for committers that aren't linked to a id
  end


  def user(login)
    return user = {
            :name => "Kalonji Bankole",
            :login => "kkbankol",
            :_rels => {
            :self => Struct.new(:get).new(Struct.new(:data).new({:attrs => {
            :company => "IBM",
            :login => "kkbankol",
            :name => "Kalonji Bankole"
            }}))          
      }
    }
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

  # def create_user
  #   u = [
  #   # client.user result
  #   {
  #         :_rels => {
  #           :self => Struct.new(:get).new(Struct.new(:data).new({:attrs => {
  #           :company => "IBM",
  #           :login => "kkbankol",
  #           :name => "Kalonji Bankole"
  #           }}))          
  #     }
  #   },

  #   {
  #         :_rels => {
  #           :self => Struct.new(:get).new(Struct.new(:data).new({:attrs => {
  #           :company => "Stark and Wayne",
  #           :login => "drnic",
  #           :name => "Dr. Nic Williams"
  #           }}))          
  #     }
  #   },

  #   {
  #         :_rels => {
  #           :self => Struct.new(:get).new(Struct.new(:data).new({:attrs => {
  #           :company => "IBM",
  #           :login => "kkbankol",
  #           :name => "Kalonji Bankole"
  #           }}))          
  #     }
  #   },

  #   {
  #         :_rels => {
  #           :self => Struct.new(:get).new(Struct.new(:data).new({:attrs => {
  #           :company => "IBM",
  #           :login => "kkbankol",
  #           :name => "Kalonji Bankole"
  #           }}))          
  #     }
  #   }
  # ]
  #   return u
  # end

  # def get_users(num)
  #   users = []
  #   for i in 1..num
  #     users << create_user
  #   end
  # end


  # def create_pull(repo)
  #   p = {}
  #   p[:attrs] = { 
  #       :repo_id => 1,
  #       :id => 1,
  #       :number => 1, 
  #       :state => "closed", 
  #       :title => "Test",
  #       :user => "User",
  #       :body => "Body",
  #       :created_at => Time.now,
  #       :updated_at => Time.now
  #   }
  #   return p
  # end


  # def create_commit(repo)
  #   repo = nil
  #   length = 40
  #   c = Hash.new
  #   c = {
<<<<<<< HEAD
  #         :attrs => {
=======
  #         
>>>>>>> 870c36a97436c8fbfc5d51fa72e1b8ff29024ca3
  #           :login => "username",  
  #           :repo_id => 1,
  #           :sha => rand(36**length).to_s(36),
  #           :message => "message",
  #           :date_created => Time.now,
  #           :commit => {
<<<<<<< HEAD
  #             :attrs => {
=======
  #             
>>>>>>> 870c36a97436c8fbfc5d51fa72e1b8ff29024ca3
  #               :author => {
  #                 :email => "user@company.com",
  #                 :name => "name"
  #               }
<<<<<<< HEAD
  #             }
  #           }
  #         }
=======
  #             
  #           }
  #         
>>>>>>> 870c36a97436c8fbfc5d51fa72e1b8ff29024ca3
  #       }
  #   return c
  # end

  # def pulls(repo_name, state)
  #   pulls = []
  #   num_pulls = rand(20..100)
  #   for i in 1..num_pulls
  #     pulls << pull
  #   end
  #   return pulls
  # end

  # def commits(repo_name)
  #   commits = []
  #   for i in 1..20
  #     commits << create_commit("repo")
  #   end
  #   return commits
  # end

  # def organization_repositories(org)
    
  # end

  # def contributors(num)
  #   num_pulls = rand(20..100)
  #   contributors = []
  #   for i in 1..num_pulls
  #     contributors << create_user
  #   end
  #   return contributors
  # end

  # def collaborators(num)
  #   num_pulls = rand(20..100)
  #   contributors = []
  #   for i in 1..num_pulls
  #     contributors << create_user
  #   end
  #   return contributors    
  # end

  # def organization_members(num)
  #   num_pulls = rand(20..100)
  #   contributors = []
  #   for i in 1..num_pulls
  #     contributors << create_user
  #   end
  #   return contributors
  # end


end