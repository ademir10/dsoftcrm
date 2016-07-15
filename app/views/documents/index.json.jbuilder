json.array!(@documents) do |document|
  json.extract! document, :id, :owner, :filename, :content_type, :file_contents
  json.url document_url(document, format: :json)
end
