json.array!(@clients) do |client|
  json.extract! client, :id, :name, :cellphone
  json.url client_url(client, format: :json)
end
