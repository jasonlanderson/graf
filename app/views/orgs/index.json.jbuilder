json.array!(@orgs) do |org|
  json.extract! org, :id, :git_id, :login, :name, :date_created, :date_updated, :source
  json.url org_url(org, format: :json)
end
