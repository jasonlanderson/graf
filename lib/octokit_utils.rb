require 'octokit'
require 'constants'

class OctokitUtils
  @@_client = nil

  def self.get_octokit_client()
  	return @@_client unless @@_client == nil

    github_conn_info = Constants.get_github_conn_info

  	@@_client = Octokit::Client.new \
	  client_id: github_conn_info['client_id'],
	  client_secret: github_conn_info['client_secret'],
	  access_token: github_conn_info['access_token'],
	  auto_paginate: true,
	  auto_traversal: true # Specify authentication information
  	user = @@_client.user github_conn_info['user'] # Login as user
  	user.login
  	user.create_authorization
  	return @@_client
  end

  def self.get_rate_limit()
    get_octokit_client().rate_limit.remaining
  end

  def self.search_users(email)
  	sleep(3.seconds) 
    search_results = get_octokit_client.search_users(email) # Should only search by email if email doesn't include the word "pair"
    return search_results
  end
end