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
    commits = client.commits(repo.full_name)
               
    commits.each { |commit|
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

      if commit[:author]
        users = [User.find_by(login: commit_info[:login]) || LoadHelpers.create_user_if_not_exist(client.user(commit_info[:login]))]
      else
        users = LoadHelpers.process_authors(c, commit_info[:email], commit_info[:names])
      end
      users.each {|user| c.users << user}
      c.save()
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
