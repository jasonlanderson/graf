require 'octokit_utils'
require 'log_level'

class LoadHelpers
  def self.create_user_if_not_exist(pr_user)
    user_login = (pr_user[:attrs][:login] || pr_user[:attrs][:items][0][:attrs][:login])
    user = User.find_by(login: user_login) 
    #puts user_obj[:attrs][:login]
    #puts user_obj[:attrs][:items][0][:attrs][:login]
    unless user
      puts "---------"
      puts "--- Creating User: #{user_login}"
      puts "---------"
      GithubLoad.log_current_msg("Creating User: #{user_login}", LogLevel::INFO)

      user_details = pr_user[:_rels][:self].get.data
      company_name = user_details[:attrs][:company]
      if ((company_name.nil?) or (company_name.downcase.include? "available") or (company_name.downcase.include? "independent") or (company_name.strip.length == 0) or company_name.nil?)
          company_name = "Independent"
      elsif (company_name.downcase.include? "vmware")
          company_name = "VMware"
      elsif ((company_name.downcase.include? "pivotal") || (company_name.downcase.include? "springsource")) 
          company_name = "Pivotal"
      elsif (company_name.downcase.include? "rbcon")
          company_name = "Rbcon"
      elsif (company_name.downcase.include? "ibm")
          company_name = "IBM"
      end

      company = nil
      if user_details[:attrs][:company] != "" && user_details[:attrs][:company] != nil
        company = create_company_if_not_exist(company_name)
      else
        company = create_company_if_not_exist("Independent")
      end


      name = "#{name.split(' ')[0]} #{name.split(' ')[2]}".titleize if (name && (name.split(' ').length > 2) && name.include?('.')) # Remove middle initial
      name = user_details[:attrs][:name].titleize if (user_details[:attrs][:name])
      
      login = user_details[:attrs][:login]
      login = login.downcase if user_details[:attrs][:login]

      user = User.create(
        :company => company,
        :git_id => user_details[:attrs][:id].to_i,
        :login => login,
        :name => name,
        :location => user_details[:attrs][:location],
        :email => user_details[:attrs][:email],
        :date_created => user_details[:attrs][:created_at],
        :date_updated => user_details[:attrs][:updated_at]
        )
      user.login = user.login.downcase if user.login
    end

    return user
  end

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

  def self.process_authors(c, email, names) 
    client = OctokitUtils.get_octokit_client
    names.each do |name| 
      next if ((name == "unknown") || email.include?("none") || name.include?("jenkins") || name.include?("Bot") || email.include?("jenkins") || email.include?("-bot") || (email.length > 25) )
      start = Time.now        
      #puts name
      user = nil
      user_type = nil
      login = nil
      user_id = nil
      search_results = nil
      num_results = 0
      if (name.split(' ').length < 2)
        name = name.downcase
      elsif ((name.split(' ').length > 2) && name.include?('.')) 
        # Remove initials becuase they don't work in search
        name = "#{name.split(' ')[0]} #{name.split(' ')[2]}" 
      else
        name = name.titleize
      end

      # Check our db for user by checking: full name, first name, email
      user = (User.find_by(name: name ) || User.find_by(login: name) || User.find_by(name: name.split(' ')[0]) || User.find_by(email: email) || User.find_by(login: email.gsub(".", "").split("@")[0]) || User.find_by(login: email.gsub(".", "").split("@")[0].chop) )

      unless user
          if email.include?("pivotal")
            user = User.create(
              :company => Company.find_by(name: "Pivotal"), 
              :name => name
              ) 
          elsif email.include?("vmware") 
            user = User.create(
              :company => Company.find_by(name: "VMware"), 
              :name => name, 
              :email => email
              )  
          elsif email.include?("rbcon") 
            user = User.create(
              :company => Company.find_by(name: "Pivotal"), 
              :name => name
              )
          else
          # Search by email, unless commit has multiple contributors
          search_results, num_results = search_email(email) if !email.include?("pair")
          # Search by name if commit submitted by pair, or if email not in github db
          search_results, num_results = search_name(name) if ( !search_results || (search_results[:attrs][:total_count] == 0))  
        
          if search_results && (num_results > 0)
            # puts "Creating record for user #{name}"
            # puts "WARNING: Search returned #{search_results[:attrs][:total_count]} results for #{name}, #{email}" if (num_results > 1)
            login = search_results[:attrs][:items][0][:attrs][:login]
            user_obj = client.user(login) 
            user = create_user_if_not_exist(user_obj) 
          else
            user = User.create(
              :name => name, 
              :email => email,
              :company => Company.find_by(name: "Independent") 
              )
          end
        end
      end
      puts "Name: #{name} Email: #{email} Time: #{Time.now - start}" if ((Time.now - start) > 6.0)
      c.users << user # Maps user to commit
      c.save()
    end
  end


    def self.search_email(email)
      sleep(3.0)
      puts "Throttling"
      search_results = OctokitUtils.search_users(email)
      num_results = search_results[:attrs][:total_count] 
      return search_results, num_results
  end
        
  def self.search_name(name)    
      sleep(3.0) # Throttling
      puts "Throttling"
      client = OctokitUtils.get_octokit_client
      if (name.split(' ').length < 2) # Only search by name if we have a first and last name. Else, we assume i
        search_results = client.search_users("#{name} in:login", options = {:sort => "followers"}) # Grabs the most active/visual member with given name. 
        num_results = search_results[:attrs][:total_count]
      else
        search_results = client.search_users("#{name} in:name", options = {:sort => "followers"}) # Grabs the most active/visual member with given name. 
        num_results = search_results[:attrs][:total_count]
      end
      return search_results, num_results
  end
end