json.array!(@companies) do |company|
  json.extract! company, :id, :name, :source
  json.url company_url(company, format: :json)
end
