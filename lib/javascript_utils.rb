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

end