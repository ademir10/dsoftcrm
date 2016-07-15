json.array!(@questions) do |question|
  json.extract! question, :id, :category_id, :description
  json.url question_url(question, format: :json)
end
