require 'load_steps/load_step'
require 'octokit_utils'
require 'log_level'
require 'constants'

class PostDeleteUsersWithoutContribs < LoadStep
  def name
    "Post Delete Users Without Pull Requests Or Commits"
  end

  def execute(*args)
    puts "Start Step: #{name}"

    # Fails since likely takes too long with the EXISTS clauses, is there an easier way?
    User.where("(NOT EXISTS (SELECT * FROM pull_requests where pull_requests.user_id = users.id)) AND (NOT EXISTS (SELECT * FROM commits_users where commits_users.user_id = users.id)) ").destroy_all

    puts "Finish Step: #{name}"    
  end

  def revert
  
  end
end

