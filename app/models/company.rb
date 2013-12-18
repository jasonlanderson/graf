class Company < ActiveRecord::Base
  def to_s
    return "Company=[name: #{name}, src: #{source}]"
  end
end
