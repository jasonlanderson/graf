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
      unless Commit.find_by(commit[:sha])
        process_commit(commit)
      end
      # if commit[:author]
      #   # find_by email?
      #    #user = User.find_by(login: commit[:author][:login].downcase) if commit[:author][:login]
      #    user = User.find_by(login: commit_info[:login])
      #    if user
      #      c.users << user
      #    else
      #      user_obj = client.user(commit[:author][:attrs][:login]) 
      #      user = LoadHelpers.create_user_if_not_exist(client.user(commit_info[:login]))
      #      c.users << user 
      #    end
      # else
      #    #names = commit[:attrs][:commit][:attrs][:author][:name].gsub(" and ", "|").gsub(", ","|").gsub(" & ", '|').split('|')
      #    # TODO should only pass the commit
      #    # TODO 
      #    #LoadHelpers.process_authors(c, email, names)
      #    LoadHelpers.process_authors(c, commit_info[:email], commit_info[:names])
      # end
    }
    pid, size = `ps ax -o pid,rss | grep -E "^[[:space:]]*#{$$}"`.strip.split.map(&:to_i)
    GithubLoad.log_current_msg("Memory before cleanup #{size} KB", LogLevel::INFO)
    commits = nil
    GC.start
    pid, size = `ps ax -o pid,rss | grep -E "^[[:space:]]*#{$$}"`.strip.split.map(&:to_i)
    GithubLoad.log_current_msg("Memory after cleanup #{size} KB", LogLevel::INFO)


    puts "Finish Step: #{name}" 
  end

  def revert

  end
end
