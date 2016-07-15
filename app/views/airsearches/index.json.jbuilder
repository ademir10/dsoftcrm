json.array!(@airsearches) do |airsearch|
  json.extract! airsearch, :id, :client, :phone, :q1, :q2, :q3
  json.url airsearch_url(airsearch, format: :json)
end
