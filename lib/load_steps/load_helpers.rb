require 'octokit_utils'
require 'log_level'
require 'json'
require 'constants'

class LoadHelpers


  # Done
  def self.merge(company_name)
    Constants.merge_companies.each { |company|
        company["alias"].each { |mapping|
          if (company_name.nil? || company_name.strip.length == 0)
             return "Independent"
          elsif company_name.downcase.include?(mapping)
             puts "Overriding user-defined company name"
             return company["name"]
          end
        }
      }
      return company_name
  end

  # Done
  def self.get_login(pr_user)
    # Get "login" value from user object.
    if pr_user[:attrs]
      user_login = (pr_user[:attrs][:login] || pr_user[:attrs][:items][0][:attrs][:login]) 
    # If not a Sawyer resource
    else
      user_login = pr_user[:login] 
    end
    return user_login
  end



  def self.create_user_if_not_exist(pr_user)
    client = OctokitUtils.get_octokit_client

    user_login = get_login(pr_user)

    # Check if user is in our DB
    user = User.find_by(login: user_login) 

    # If user is not in DB, create
    unless (user and user.git_id)
      puts "---------"
      puts "--- Creating User: #{user_login}"
      puts "---------"
      GithubLoad.log_current_msg("Creating User: #{user_login}", LogLevel::INFO)

      # Ensure we have the full user object (Which we don't when using HTTParty api requests)
      pr_user = client.user(user_login) if !pr_user[:_rels]
      
      # Run GET request to get rest of user data
      user_details = pr_user[:_rels][:self].get.data

      # Standardize company name, removing initial, capitilzing, etc
      company_name = merge(user_details[:attrs][:company])
      company = create_company_if_not_exist(company_name)

      # TODO, Determine whether always removing middle initial is such a good idea. Searching with initial seems to break github search

      # Format name/login when applicable
      name = format_name(user_details[:attrs][:name]) if (user_details[:attrs][:name])
      login = user_details[:attrs][:login].downcase if user_details[:attrs][:login]

      user = User.create(
        :company => company,
        :git_id => user_details[:attrs][:id].to_i,
        :login => (login ? login.downcase : nil),
        :name => name,
        :location => user_details[:attrs][:location],
        :email => user_details[:attrs][:email],
        :date_created => user_details[:attrs][:created_at],
        :date_updated => user_details[:attrs][:updated_at]
        )
    end

    return user
  end


  # Done
  def self.create_company_if_not_exist(company_name)
    company = Company.find_by(name: company_name)

    unless company
      puts "---------"
      puts "--- Creating Company: #{company_name}"
      puts "---------"
      GithubLoad.log_current_msg("Creating Company: #{company_name}", LogLevel::INFO)

      company = Company.create(
        :name => company_name
      )
    end

    return company
  end

  # Done
  def self.format_name(name)
      if (name.nil? || (name.strip == ""))
        name = "No Name Listed"
      elsif (name.split(' ').length < 2) # If login
        name = name.downcase      
      elsif (name.split(' ').length > 2) # If name includes middle initial, remove it, as initials don't work with search
        name = "#{name.downcase.split(' ')[0]} #{name.downcase.split(' ')[2]}".titleize 
      else
        name = name.titleize
      end
  end

  def self.name_match(search_results, name)
    client = OctokitUtils.get_octokit_client
    top_result = search_results[:attrs][:items][0][:attrs][:login]
    #puts client.orgs(top_result).inspect
    user_obj = client.user(top_result)
    if (user_obj[:attrs][:name] and (format_name(user_obj[:attrs][:name]) == name)) or (user_obj[:attrs][:login] and (user_obj[:attrs][:login].downcase == name) )
      return true
    else
      return false
    end
  end



  def self.check_db_for_user(name, email)
        user = ( User.find_by(name: name ) \
              || User.find_by(login: name) \
              || User.find_by(name: name.split(' ')[0]) \
              || User.find_by(email: email) \
              || User.find_by(login: email.gsub(".", "").split("@")[0]) \
              || User.find_by(login: email.gsub(".", "").split("@")[0].chop) \
        )
        return user
  end

  def self.skip?(n, email)    
    if  (  n.include?("unknown") \
        || n.include?("jenkins") \
        || n.include?("Bot") \
        || email.include?("jenkins") \
        || email.include?("-bot") \
        || (email.length > 25) \
        )
      return true
    else
      return false
    end
  end

  def self.associate_company_email(email)
    Constants.get_email_to_company.each {|co_email|
      if co_email["alias"].any? {|v| email.include?(v)}
        return co_email["name"]
      end
    }
  end

  def self.process_results(search_results, num_results)
      # Even if results are returned from searching for name, we need the name_match function to validate search results. 
      # This is done by ensuring result name (or login) directly matches with given commit author name
      if search_results and (num_results > 0) and name_match(search_results, name)
        login = search_results[:attrs][:items][0][:attrs][:login]
        user_obj = client.user(login) 
        puts "Successfully found reference of '#{name}' / #{email} in github db"
        user = create_user_if_not_exist(user_obj) 
      else
        puts "Failed to find reference of '#{name}' / #{email} in github db"
        user = User.create(
          :name => name, 
          :email => email,
          :company => Company.find_by(name: "Independent") 
        )
      end
      return user
  end


  def self.process_authors(c, email, names) 
    client = OctokitUtils.get_octokit_client
    names.each do |n| 
      # Name shouldn't be processed if it's unknown, a bot, etc.
      next if skip?(n, email)
      start = Time.now        
      user, user_type, login, user_id, search_results = nil
      num_results = 0
      name = format_name(n)
      # Check our db for user by checking: full name, first name, email
      user = check_db_for_user(name, email)
      unless user
        # If we can id user by email
        company_name = associate_company_email(email)
        if company_name
          user = User.create(
            :company => Company.find_by(name: company_name), 
            :name => name,
            :email => email
            ) 
        # Else try searching by email, and then by name
        else
          # Search by email, unless commit has multiple contributors
          search_results, num_results = search(email) unless (email.include?("pair") || email.include?("none") || (email.length > 25))
          # Search by name if commit submitted by pair, or if email not in github db
          search_results, num_results = search(name) if ( !search_results || (search_results[:attrs][:total_count] == 0))
          user = process_results(search_results, num_results)
        end
      end
      puts "Took #{Time.now - start}s to process #{name} / #{email} " if ((Time.now - start) > 6.0)
      c.users << user # Maps user to commit
      c.save()
    end
  end

  # Done
  def self.get_search_type(identifier)
      if (identifier.split(' ').length > 1)
          return "name"
      elsif (identifier.include?('@') && identifier.include?('.'))
          return "email"
      else
          return "login" 
      end
  end

  # TODO
  # How should we do tests here, if we're not reaching out to github?
  def self.search(identifier)
      sleep(3.0)
      search_type = get_search_type(identifier)
      puts "Searching by #{search_type} for #{identifier} (Throttling 3s)"
      client = OctokitUtils.get_octokit_client
      #search_type = (name.split(' ').length < 2) ? "login" : "name"
      search_results = client.search_users("#{identifier} in:#{search_type}", options = {:sort => "followers"}) 
      num_results = search_results[:attrs][:total_count]
      return search_results, num_results
  end

  # Done
  def self.get_stackalytics_JSON()
    return JSON.parse(HTTParty.get("http://raw.github.com/stackforge/stackalytics/master/etc/default_data.json"))
  end

end
