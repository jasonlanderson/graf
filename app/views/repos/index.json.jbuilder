json.array!(@repos) do |repo|
  json.extract! repo, :id, :git_id, :name, :full_name, :fork, :date_created, :date_updated, :date_pushed, :org
  json.url repo_url(repo, format: :json)
end
