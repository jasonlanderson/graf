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
      GithubLoad.log_current_msg("The following error occured when processing repo #{ repo.full_name } ...", LogLevel::ERROR)
      GithubLoad.log_current_msg(e.message, LogLevel::ERROR)
      GithubLoad.log_current_msg(e.backtrace.join("\n"), LogLevel::ERROR)
      return nil
    end
    if commits && commits.length > 0
      commits.each { |commit|
        commit_info = Constants.get_commit_info(commit)
        # Create record of commit
        c = LoadHelpers.create_commit(commit_info, repo.id)      
        users = []
        if commit[:author]
          users << (User.find_by(login: commit_info[:login]) || LoadHelpers.create_user_if_not_exist(client.user(commit_info[:login])))
        else
          users = LoadHelpers.process_authors(commit_info[:email], commit_info[:names])
        end
        users.each {|user| c.users << user}
        c.save()
      }
    end
    puts "Finish Step: #{name}" 
  end

  def revert

  end
end
