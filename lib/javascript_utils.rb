require 'json'


class JavascriptUtils
  def self.get_pull_request_stats(dataset, label_index, val_index)
  	result = '{ "response":['
    dataset.each{ |rec|
      if result != '{ "response":['
        result += ','
      end
      
      label = rec[label_index]
      if label == nil || label == ''
      	label = "Independent"
      end

      result += "{ \"label\": \"#{label}\", \"data\": #{rec[val_index]} }"
    }
    result += ']}'
    return result
  end


  def self.get_flot_line_chart_json(dataset, label_index, time_index, val_index)
      response = []
      current_hash = nil 
      #dataset = [["independent", "1301630400000", 22], ["IBM", "1304722400000", 4], ["IBM", "1304222400000", 8] ]
      dataset.each{ |rec|
        # Create key in hash for contributor if it doesn't exist. Set the key's value as an empty array
        if current_hash.nil? || current_hash["label"] != rec["label_index"]
          response << current_hash if !current_hash.nil?          
          current_hash = {"label" => rec["label_index"], "data"  => []}
        end
        current_hash["data"] << [rec[time_index], rec[val_index]]
        # if !response.include?(rec[0]) #.has_key?(rec[0])
        #   response[rec[0]] ||= {} 
        #   # Push an array containing timestamp and num of contributions
        #   response[rec[0]]["label"] ||= rec[0]
        #   response[rec[0]]["data"] ||= []
        # end
        # 
      }
      response << current_hash if !current_hash.nil?         
      return response.to_json
  end

#[["independent", 28395723, 22], ["Basho Technologies", 28439742, 3]]

end