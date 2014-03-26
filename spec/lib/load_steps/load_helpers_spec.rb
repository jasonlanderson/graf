require "spec_helper"
require "load_steps/load_helpers"
require 'faker'
require 'db_utils'

describe LoadHelpers do
  
  it 'contains no initial?' do
    name = "Kalonji K. bankole"
    expect(LoadHelpers.format_name(name)).to match("Kalonji Bankole")
  end
  
  it 'capitalized?' do
    name = "kalonji BANKOLE"
    expect(LoadHelpers.format_name(name)).to match "Kalonji Bankole"
  end

  # self.merge
  it 'merges similar companies' do
     # This merge function should be more generic by removing "Corporation", ".Inc", etc
     company = "IBM Corporation"
     expect(LoadHelpers.merge(company)).to match("IBM")

  end

  it 'can get id type' do
    identifier = "Kalonji Bankole"
    expect(LoadHelpers.get_search_type(identifier)).to match("name")

    identifier = "kkbankol"
    expect(LoadHelpers.get_search_type(identifier)).to match("login")
    
    identifier = "kkbankol@us.ibm.com"
    expect(LoadHelpers.get_search_type(identifier)).to match("email")
  end

  it 'can extract login' do
    
    # Octokit.pulls("repo")[0][:user][:attrs][:login]
    user = {
              :attrs => {
              :company => "IBM",
              :login => "kkbankol",
              :name => "Kalonji Bankole"
          }
    }
    expect(LoadHelpers.get_login(user)).to match("kkbankol")

    # Octokit.search_users(username)[:items][0][:attrs][:login]
    user = {
          :attrs => {            
            :items => [{
              :attrs => {
                :login => "kkbankol"
              }
            }]  
          }
    }

    expect(LoadHelpers.get_login(user)).to match("kkbankol")


    user = {
              :company => "IBM",
              :login => "kkbankol",
              :name => "Kalonji Bankole"
    }

    expect(LoadHelpers.get_login(user)).to match("kkbankol")

  end


  # self.create_user_if_not_exist
  it "can create a user record" do
    user = { :attrs => { :company => "IBM", :login => "kkbankol", :name => "Kalonji Bankole" }}
    DBUtils.delete_all_data
    expect(User.all.length).to match(0)
    expect(User.find_by(name: "Kalonji Bankole")).to match(nil)
    LoadHelpers.create_user_if_not_exist(user)
    expect(User.all.length).to match(1)
    #expect(User.find_by(name: "Kalonji Bankole")).to exist
    expect(User.find_by(name: "Kalonji Bankole").login).to match("kkbankol")
    DBUtils.delete_all_data
  end
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
  # it 'all users have a company' do
  #   # Create 20 to 100 mock users
  #   user_count = rand(20..100)
  #   create_fake_users(user_count)
  #   users = User.all

  #   # Remove the company_id field from 15 random users
  #   for i in 1..(15)
  #     User.find_by(id: rand(user_count)).company_id = nil
  #   end

  #   User.where(company_id: nil)

  #   expect(User.where(company_id: nil).length).to match(0)
  #   User.destroy_all
  # end

  # Test that there are no companies without users
  it 'all companies have users' do
    expect(Company.where("NOT EXISTS (SELECT * FROM users where companies.id = users.company_id)").length).to match(0)
  end

end