require "load_steps/load_helpers"
require 'faker'

describe LoadHelpers do
  #name = "Kalonji K. bankole"
  #it 'contains no initial?' do
  #	expect(LoadHelpers.format_name(name)).to equal("Kalonji Bankole")
  #end
  #
  #name = "kalonji BANKOLE"
  #it 'capitalized?' do
  #	expect LoadHelpers.format_name(name).to equal "Kalonji Bankole"
  #end

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
        :git_id => rand(6),
        :login => Faker::Internet.user_name,
        :name => Faker::Name.name,
        #:location => , 
        :email => Faker::Internet.email,
        :created_at => rand(2.years).ago
      )
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