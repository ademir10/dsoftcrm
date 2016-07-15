json.array!(@meetings) do |meeting|
  json.extract! meeting, :id, :name, :cellphone, :start_time, :clerk_id, :research_path, :research_id
  json.url meeting_url(meeting, format: :json)
end
