json.array!(@orgs) do |org|
  json.extract! org, :id, :git_id, :login, :name, :org_type, :date_created, :date_updated
  json.url org_url(org, format: :json)
end
