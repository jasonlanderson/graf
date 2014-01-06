json.array!(@github_loads) do |github_load|
  json.extract! github_load, :id, :load_start_time, :load_complete_time, :initial_load
  json.url github_load_url(github_load, format: :json)
end
