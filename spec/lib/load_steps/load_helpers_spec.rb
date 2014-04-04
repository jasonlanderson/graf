require "spec_helper"
require "load_steps/load_helpers"
require 'faker'
require 'db_utils'
require 'mock_octokit'

 
context LoadHelpers do
  before(:each) do
    DBUtils.delete_all_data
    class OctokitUtils
      def self.get_octokit_client()
        puts "Returning MOCK object"
        return MockOctokit.new
      end
    end
  end

  describe "search" do          
    it "should return empty if no results" do
      expect(LoadHelpers.search("NOT A USER")[:total_count]).to match 0
    end

    it "should return a user login" do
      result = LoadHelpers.search("Kalonji Bankole")
      expect(result[:items][0][:attrs][:login]).to match "kkbankol"
      expect(result[:total_count]).to match 1
    end

    it "can process results" do
      name = "Mock User"
      email = "mock@test.com"
      search_results = LoadHelpers.search(name)
      LoadHelpers.process_search_results(search_results, name, email)
      expect(User.find_by(name: name)).to be
      
      name = "Kalonji Bankole"
      email = "kkbankol@us.ibm.com"
      search_results = LoadHelpers.search(name)
      LoadHelpers.process_search_results(search_results, name, email)
      expect(User.find_by(name: name)).to be
    end

    it "ensures search results match exactly" do
      search_results = LoadHelpers.search("Kalonji Bankole")
      expect(LoadHelpers.name_match(search_results, "Kalonji Bankole")).to match true
      expect(LoadHelpers.name_match(search_results, "Kalon Bankole")).to match false
    end
  end

  describe "get_search_type" do
    it 'can identify name' do
      identifier = "Kalonji Bankole"
      expect(LoadHelpers.get_search_type(identifier)).to match "name"

      # TODO set this as a constant
      identifier = "No Name Listed"
      expect(LoadHelpers.get_search_type(identifier)).to match "name"    
    end

    it 'can identify login' do
      identifier = "kkbankol"
      expect(LoadHelpers.get_search_type(identifier)).to match "login"
    end

    it 'can identify email' do
      identifier = "kkbankol@us.ibm.com"
      expect(LoadHelpers.get_search_type(identifier)).to match "email"
    end
  end

  describe "format names" do
    it 'removes initial' do
      name = "Kalonji K. bankole"
      expect(LoadHelpers.format_name(name)).to match "Kalonji Bankole"
    end
    
    it 'titleized?' do
      name = "kalonji BANKOLE"
      expect(LoadHelpers.format_name(name)).to match "Kalonji Bankole"
    end

    it 'catches unnamed users' do
      name = "        "
      expect(LoadHelpers.format_name(name)).to match "No Name Listed"
      name = nil
      expect(LoadHelpers.format_name(name)).to match "No Name Listed"
    end 
  end

  describe 'merges similar companies' do
    it 'merge' do
      # This merge function should be more generic by removing "Corporation", ".Inc", etc from all companies
       company = "IBM Corporation"
       expect(LoadHelpers.merge(company)).to match "IBM"
    end

    it "identifies company based on email" do
      email = "user@us.ibm.com"
      expect(LoadHelpers.associate_company_email(email)).to match "IBM"
      email = "user@10gen.com"
      expect(LoadHelpers.associate_company_email(email)).to match "Mongo"
      email = "user@ebay.com"
      expect(LoadHelpers.associate_company_email(email)).to match "eBay Inc."
    end
  end


  describe 'can query db' do
    it "can create a company record" do
      company = "IBM"
      expect(Company.all.length).to match 0
      expect(Company.find_by(name: "IBM")).to match nil
      LoadHelpers.create_company_if_not_exist(company)
      expect(Company.find_by(name: "IBM").name).to be
    end

    it "can create a user record" do
      user = { :attrs => { :company => "IBM", :login => "kkbankol", :name => "Kalonji Bankole" }}
      expect(User.all.length).to match 0
      expect(User.find_by(name: "Kalonji Bankole")).to match nil
      LoadHelpers.create_user_if_not_exist(user)
      expect(User.find_by(name: "Kalonji Bankole")).to be

      DBUtils.delete_all_data
      
      LoadHelpers.create_user("Kalonji Bankole", "kkbankol@us.ibm.com")
      expect(User.find_by(name: "Kalonji Bankole")).to be      
      LoadHelpers.create_user("Unknown User", "user@unknown.com")      
      expect(User.find_by(name: "Unknown User")).to be
    end

    # Test that there are no companies without users
    it 'ensures all companies have users' do
      expect(Company.where("NOT EXISTS (SELECT * FROM users where companies.id = users.company_id)").length).to match(0)
    end

    it 'fetches users from database' do
      user1 = LoadHelpers.create_user("Ryan Morgan", "rmorgan@gopivotal.com")
      user2 = LoadHelpers.create_user("tlang", "tlang@pivotallabs.com")
      expect(LoadHelpers.check_db_for_user("Ryan Morgan")).to be
      expect(LoadHelpers.check_db_for_user("tlang")).to be
    end


    it 'does not process "bots"' do
      # TODO Unsure if this is the best course of action. Do we want always want to skip commits that have no reference to a human author?
      expect(LoadHelpers.skip?("Jenkins Bot", "jenkins@jenkins-slave2.sf.pivotallabs.com")).to match true
      expect(LoadHelpers.skip?("Kalonji Bankole", "kkbankol@us.ibm.com")).to match false
    end
  end

  describe "can fetch external data" do
    it "can fetch and parse stackalytics data" do
        expect(LoadHelpers.get_stackalytics_JSON().class).to match Hash
    end
  end

  describe "can process authors" do
    it "can process a single user" do
      email = "kkbankol@us.ibm.com"
      names = ["Kalonji Bankole"]
      result = LoadHelpers.process_authors(email, names)
      expect( result.class ).to match Array
      expect( result[0].class).to match User
    end

    it "can process an array of users" do
      email = "pair+ryan+slevine@pivotallabs.com"
      names = ["Ryan Spore", "Stephen Lavine"]
      result = LoadHelpers.process_authors(email, names)
      expect(User.find_by(name: names[0])).to be
      expect(User.find_by(name: names[1])).to be
      expect( result.class ).to match Array
      expect( result[0].class).to match User
    end
  end

  xdescribe LoadHelpers do   

    it 'can extract login' do
      
      # Octokit.pulls("repo")[0][:user][:attrs][:login]
      user = {
                :attrs => {
                :company => "IBM",
                :login => "kkbankol",
                :name => "Kalonji Bankole"
            }
      }
      expect(LoadHelpers.get_login(user)).to match "kkbankol"

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

      expect(LoadHelpers.get_login(user)).to match "kkbankol"


      user = {
                :company => "IBM",
                :login => "kkbankol",
                :name => "Kalonji Bankole"
              }

      expect(LoadHelpers.get_login(user)).to match "kkbankol"
    end

    xit "should place users w/no company under Independent" do
      user = { :attrs => { :company => nil, :login => "kkbankol", :name => "Kalonji Bankole" }}
      expect(User.all.length).to match 0
      expect(User.find_by(name: "Kalonji Bankole")).to match nil
      LoadHelpers.create_user_if_not_exist(user)
      expect(User.all.length).to match 1
      #expect(User.find_by(name: "Kalonji Bankole")).to exist # This is the correct way to do it
      expect(User.find_by(name: "Kalonji Bankole").company.name).to match "Independent"
    end

    

    # it "all users have contributions"

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

  end


end

