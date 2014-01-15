require 'octokit'

class OctokitUtils
  @@_client = nil

  def self.get_octokit_client()
  	return @@_client unless @@_client == nil
  	@@_client = Octokit::Client.new \
	  client_id: '949149798908ec942301',
	  client_secret: '70563cd761fafd0df22b5f4cb40a68b2b9afc9f4',
	  access_token: "1dd6279ced24c313519c3065e6260955ae94e94d",
	  auto_paginate: true,
	  auto_traversal: true # Specify authentication information
	user = @@_client.user 'kkbankol' # Login as user
	user.login
	user.create_authorization
	return @@_client
  end

  def self.get_rate_limit()
    get_octokit_client().rate_limit_remaining
  end

  def self.search_users(email)
  	sleep(3.seconds) 
    search_results = get_octokit_client.search_users(email) # Should only search by email if email doesn't include the word "pair"
    return search_results
  end
end