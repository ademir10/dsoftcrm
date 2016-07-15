json.array!(@packsearches) do |packsearch|
  json.extract! packsearch, :id
  json.url packsearch_url(packsearch, format: :json)
end
