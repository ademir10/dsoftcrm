json.array!(@solutions) do |solution|
  json.extract! solution, :id, :answer_id, :description
  json.url solution_url(solution, format: :json)
end
