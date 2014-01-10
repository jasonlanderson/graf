class DateUtils

  def self.human_slash_date_format_to_db_format(input_date_str)
    # If empty, return empty
    if input_date_str == nil || input_date_str == ""
      return input_date_str
    end

    date_array = input_date_str.split('/')
    return "#{date_array[2]}-#{date_array[0]}-#{date_array[1]}"
  end
  
end