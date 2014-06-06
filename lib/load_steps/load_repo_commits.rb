require 'load_steps/load_step'
require 'octokit_utils'
require 'log_level'
require 'load_steps/load_helpers'

class LoadRepoCommits < LoadStep

  def name
    "Load Repo Commits"
  end

  def execute(*args)
    repo = args[0]
    puts "Start Step: #{name}"


    puts "---------"
    puts "--- Loading Commits for #{repo.full_name}"
    puts "---------"
    GithubLoad.log_current_msg("Loading Commits for #{repo.full_name}", LogLevel::INFO)

    client = OctokitUtils.get_octokit_client
    begin
      commits = client.commits(repo.full_name)
    # TODO, try to only catch Octokit Error  
    rescue => e
      GithubLoad.log_current_msg("The following error occured...", LogLevel::ERROR)
      GithubLoad.log_current_msg(e.message, LogLevel::ERROR)
      GithubLoad.log_current_msg(e.backtrace.join("\n"), LogLevel::ERROR)
      return nil
    end
    commits.each { |commit|
      #LoadHelpers.process_commit(commit) # Can comment out everything below 
      commit_info = Constants.get_commit_info(commit)
      #email = commit[:attrs][:commit][:attrs][:author][:email]
      email = commit_info[:email]
      # Create record of commit
      c = Commit.create(
        :repo_id => repo.id,
        :sha => commit_info[:sha], # Change sha to string
        :message => commit_info[:message],#commit[:attrs][:commit][:attrs][:message],
        :date_created => commit_info[:date_created] #commit[:attrs][:commit][:attrs][:author][:date]
      )
      users = []
      if commit[:author]
        users << (User.find_by(login: commit_info[:login]) || LoadHelpers.create_user_if_not_exist(client.user(commit_info[:login])))
      else
        users = LoadHelpers.process_authors(commit_info[:email], commit_info[:names])
      end
      users.each {|user| c.users << user}
      c.save()
    }

    puts "Finish Step: #{name}" 
  end

  def revert

  end
end
