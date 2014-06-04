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
      last_completed = LoadHelpers.get_last_completed_date
      commits = client.commits_since(repo.full_name, last_completed)
    # TODO, try to only catch Octokit Error  
    rescue => e
      GithubLoad.log_current_msg("The following error occured...", LogLevel::ERROR)
      GithubLoad.log_current_msg(e.message, LogLevel::ERROR)
      GithubLoad.log_current_msg(e.backtrace.join("\n"), LogLevel::ERROR)
      return nil
    end
    commits.each { |commit|
      # TODO, hacky, find a cleaner way to do this
      if !Commit.find_by(sha: commit[:sha], repo_id: Repo.find_by(full_name: repo.full_name).id)
        process_commit(commit)
      end
    }

    puts "Finish Step: #{name}" 
  end

  def revert

  end
end
