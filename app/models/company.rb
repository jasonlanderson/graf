class Company < ActiveRecord::Base
  def to_s
    return "Company=[name: #{name}]"
  end
end
