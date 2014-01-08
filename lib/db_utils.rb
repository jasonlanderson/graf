require "rdms"

class DBUtils
  
  @@current_db = nil

  def self.get_current_db_type
    if @@current_db
      return @@current_db
    end

    adapter = Rails.configuration.database_configuration[Rails.env]['adapter']
    if adapter.include?("sqlite")
      @@current_db = RDMS::SQLITE
    elsif adapter.include?("mysql")
      @@current_db = RDMS::MYSQL
    else
      puts "ERROR: Unknown DB '#{adapter}'"
    end
  end

  def self.get_month(column)
    if get_current_db_type == RDMS::SQLITE
      return "strftime('%m', #{column})"
    elsif get_current_db_type == RDMS::MYSQL
      return "EXTRACT(MONTH FROM #{column})"
    else
      puts "ERROR: Unknown DB '#{get_current_db_type}'"
    end
  end

  def self.get_year(column)
    if get_current_db_type == RDMS::SQLITE
      return "strftime('%Y', #{column})"
    elsif get_current_db_type == RDMS::MYSQL
      return "EXTRACT(YEAR FROM #{column})"
    else
      puts "ERROR: Unknown DB '#{get_current_db_type}'"
    end
  end

  def self.get_date_difference(date1, date2)
    if get_current_db_type == RDMS::SQLITE
      return "julianday(IFNULL(#{date1}, date('now'))) - julianday(#{date2})"
    elsif get_current_db_type == RDMS::MYSQL
      return "TIMEDIFF(IFNULL(#{date1}, date('now')), #{date2}) / (60*60*24)"
    else
      puts "ERROR: Unknown DB '#{get_current_db_type}'"
    end
  end

  def self.get_month_by_name(date)
    if get_current_db_type == RDMS::SQLITE
      return "case strftime('%m', #{date}) when '01' then 'January' when '02' then 'Febuary' when '03' then 'March' when '04' then 'April' when '05' then 'May' when '06' then 'June' when '07' then 'July' when '08' then 'August' when '09' then 'September' when '10' then 'October' when '11' then 'November' when '12' then 'December' else '' end"
    elsif get_current_db_type == RDMS::MYSQL
      return "DATE_FORMAT(#{date},'%M')"
    else
      puts "ERROR: Unknown DB '#{get_current_db_type}'"
    end
  end

  def self.get_quarter_by_name(date)
    if get_current_db_type == RDMS::SQLITE
      return "case strftime('%m', #{date}) when '01' then 'January' when '02' then 'Febuary' when '03' then 'March' when '04' then 'April' when '05' then 'May' when '06' then 'June' when '07' then 'July' when '08' then 'August' when '09' then 'September' when '10' then 'October' when '11' then 'November' when '12' then 'December' else '' end"
    elsif get_current_db_type == RDMS::MYSQL
      return "DATE_FORMAT(#{date},'%M')"
    else
      puts "ERROR: Unknown DB '#{get_current_db_type}'"
    end
  end

end