require 'load_steps/load_step'
require 'octokit_utils'
require 'log_level'
require 'load_steps/load_helpers'

class LoadRepoPullRequests < LoadStep

  def name
    "Load Repo Pull Requests"
  end

  def execute(*args)
    raise ArgumentError, "Too many arguments" if args.length > 1
    repo = args[0]
    puts "Start Step: #{name}"


    puts "---------"
    puts "--- Loading PRs for #{repo.full_name}"
    puts "---------"
    #@@current_load.log_msg("Loading PRs for #{repo.full_name}", LogLevel::INFO)

    client = OctokitUtils.get_octokit_client

    pull_requests = client.pulls(repo.full_name, state = "open")
    pull_requests.concat(client.pulls(repo.full_name, state = "closed"))
    puts "PULLS #{pull_requests.length}"
    pull_requests.each { |pr|
      # Get user and insert if doesn't already exist
      user = LoadHelpers.create_user_if_not_exist(pr[:attrs][:user]) if pr[:attrs][:user]

      PullRequest.create(
        :repo_id => repo.id,
        :user_id => (user.nil? ? nil : user.id),
        :git_id => pr[:attrs][:id].to_i,
        :pr_number => pr[:attrs][:number],
        :body => pr[:attrs][:body],
        :title => pr[:attrs][:title],
        :date_created => pr[:attrs][:created_at],
        :date_closed => pr[:attrs][:closed_at],
        :date_updated => pr[:attrs][:updated_at],
        :date_merged => pr[:attrs][:merged_at],
        :state => (pr[:attrs][:merged_at].nil? ? pr[:attrs][:state] : "merged")
        )
    }



    puts "Finish Step: #{name}" 
  end

  def revert

  end
end