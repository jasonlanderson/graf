class JavascriptUtils
  def self.get_pull_request_stats(dataset, label_index, val_index)
  	result = "["
    dataset.each{ |rec|
      if result != "["
        result += ","
      end
      
      label = rec[label_index]
      if label == nil || label == ""
      	label = "Independent"
      end

      result += "{ label: \"#{label}\", data: #{rec[val_index]} }"
    }
    result += "]"
    return result
  end


  def self.create_pull_request_table(dataset, label_index, val_index)
    result = "<thead><tr><th>Users</th><th>Contributions</th></tr></thead><tbody>"
    dataset.each{ |rec|

      result += "<tr><td> #{rec[label_index]} </td><td> #{rec[val_index]} </td></tr>"
    }
    return result
  end

end