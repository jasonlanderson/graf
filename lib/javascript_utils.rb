require 'json'
require 'date'


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

      result += "{ \"label\": #{label.to_json}, \"data\": #{rec[val_index]} }"
    }
    result += ']}'
    return result
  end

  def self.get_quarter(month)
    if month <= 3
      return 1
    elsif (month > 3) && (month <= 6)
      return 4
    elsif (month > 6) && (month <= 9)
      return 7
    elsif (month > 9) && (month <= 12)
      return 10
    end      
  end

  def self.convert_to_epoch(timeframe, timestamp)
    case timeframe
      when "month"
        return (timestamp * 1000)
      when "quarter"
        puts "TIMESTAMP #{timestamp}"
        m = DateTime.strptime(timestamp.to_s, '%s').month
        y = DateTime.strptime(timestamp.to_s, '%s').year
        return (Date.new(y, get_quarter(m)).to_time.to_i * 1000)
      when "year"
        return (Date.new(DateTime.strptime(timestamp.to_s, '%s').year).to_time.to_i * 1000)
    end
  end

  def self.merge_timestamps(result)
    merged = []
    result.each {|x|
      tmp = {}
      datasets = []
      x["data"].each {|y|
        if !tmp[y[0]]
          tmp[y[0]] ||= y[1]
        else
          tmp[y[0]] += y[1]
        end
      }
      #x["data"] = tmp
      merged << { "label" => x["label"], "data" => tmp.to_a}
    }
    return merged
  end

  def self.get_flot_line_chart_json(dataset, label_index, time_index, val_index, timeframe)
    response = []
    current_hash = nil               
    #dataset = [["independent", "1301630400000", 22], ["IBM", "1304722400000", 4], ["IBM", "1304222400000", 8] ]
    dataset.each{ |rec|
      puts "REC #{rec}"
      # rec = ["independent", "1301630400000", 22]
      # Create key in hash for contributor if it doesn't exist. Set the key's value as an empty array
      if current_hash.nil? || current_hash["label"] != rec[label_index]
        response << current_hash if !current_hash.nil?          
        current_hash = {"label" => rec[label_index], "data"  => []}
      end
      # current_hash["data"] << [rec[time_index] * 1000, rec[val_index]]
      current_hash["data"] << [convert_to_epoch(timeframe, rec[time_index]), rec[val_index]]
      puts "CURRENT HASH #{current_hash}"
    }
    response << current_hash if !current_hash.nil? 
    return merge_timestamps(response).to_json
    #return response.to_json
  end

#[["independent", 28395723, 22], ["Basho Technologies", 28439742, 3]]

end