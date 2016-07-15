json.array!(@rodosearches) do |rodosearch|
  json.extract! rodosearch, :id
  json.url rodosearch_url(rodosearch, format: :json)
end
