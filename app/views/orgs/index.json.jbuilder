json.array!(@orgs) do |org|
  json.extract! org, :id, :git_id, :name, :date_created, :date_updated
  json.url org_url(org, format: :json)
end
