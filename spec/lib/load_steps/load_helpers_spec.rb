require "load_steps/load_helpers"

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

  # self.merge
  it 'merges similar companies' do
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



  it 'searching commit author'
     name = "Kalonji Bankole"
     LoadHelpers.search_name()

     name = "Matthew"

  end


  # Test that there are no companies with nil or "" as a name

  # Test that there are no users with nil or "" as a name
end
