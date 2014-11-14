class DateUtils

  def self.human_slash_date_format_to_db_format(input_date_str)
    # If empty, return empty
    if input_date_str == nil || input_date_str == ""
      return input_date_str
    end

    date_array = input_date_str.split('/')
    return "#{date_array[2]}-#{date_array[0]}-#{date_array[1]}"
  end

  def self.db_format_to_human_slash_date_format(input_date)
    # If empty, return empty
    if input_date == nil 
      return ""
    end

    if input_date.is_a? String
      date_array = input_date.split('-')
      return "#{date_array[1]}/#{date_array[2]}/#{date_array[0]}"
    else
      return input_date.strftime("%m/%d/%Y")
    end
  end
  
end