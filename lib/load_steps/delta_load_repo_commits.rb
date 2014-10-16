require 'load_steps/load_helpers'
require 'load_steps/load_step'
require 'octokit_utils'
require 'log_level'

class DeltaLoadRepoCommits < LoadStep

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
      last_completed = LoadHelpers.parse_last_load_date
      commits = LoadHelpers.github_commits_since(client, repo.full_name, last_completed)
    rescue Exception
      # GithubLoad.log_current_msg("The following error occured...", LogLevel::ERROR)
      # GithubLoad.log_current_msg(e.message, LogLevel::ERROR)
      # GithubLoad.log_current_msg(e.backtrace.join("\n"), LogLevel::ERROR)
      return nil
    end
    if commits && (commits.length > 0)
      commits.each { |commit|
        # TODO, hacky, find a cleaner way to do this
        # Same commit can be in two repositories apparently 
        repo_id = Repo.find_by(full_name: repo.full_name).id
        if !Commit.find_by(sha: commit[:sha], repo_id: repo_id)
          c = LoadHelpers.create_commit(commit, repo.id)
          users = []
          if commit[:author]
            users << (User.find_by(login: commit_info[:login]) || 
              LoadHelpers.create_user_if_not_exist(LoadHelpers.github_user(client, commit_info[:login])))
          else
            users = LoadHelpers.process_authors(commit_info[:email], commit_info[:names])
          end
          users.each {|user| c.users << user}
          c.save()
        end
      }
    end
    puts "Finish Step: #{name}" 
  end

  def revert

  end
end
