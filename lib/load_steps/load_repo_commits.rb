require 'load_steps/load_step'
require 'octokit_utils'
require 'log_level'
require 'load_steps/load_helpers'

class LoadRepoCommits < LoadStep

  def name
    "Load Repo Commits"
  end

  def execute(*args)
    raise ArgumentError, "Too many arguments" if args.length > 1
    repo = args[0]
    puts "Start Step: #{name}"


    puts "---------"
    puts "--- Loading Commits for #{repo.full_name}"
    puts "---------"
    GithubLoad.log_current_msg("Loading Commits for #{repo.full_name}", LogLevel::INFO)

    client = OctokitUtils.get_octokit_client
    commits = client.commits(repo.full_name)
               
    commits.each { |commit|
      email = commit[:attrs][:commit][:attrs][:author][:email]

      # Create record of commit
      c = Commit.create(
        :repo_id => repo.id,
        :sha => commit[:sha], # Change sha to string
        :message => commit[:attrs][:commit][:attrs][:message],
        :date_created => commit[:attrs][:commit][:attrs][:author][:date]
      )

      if commit[:author]
         user = User.find_by(login: commit[:author][:attrs][:login].downcase) if commit[:author][:attrs][:login]
         if user
           c.users << user
         else
           user_obj = client.user(commit[:author][:attrs][:login]) 
           user = LoadHelpers.create_user_if_not_exist(user_obj)
           c.users << user 
         end
      else
         names = commit[:attrs][:commit][:attrs][:author][:name].gsub(" and ", "|").gsub(", ","|").gsub(" & ", '|').split('|')
         LoadHelpers.process_authors(c, email, names)
      end
    }


    puts "Finish Step: #{name}" 
  end

  def revert

  end
end