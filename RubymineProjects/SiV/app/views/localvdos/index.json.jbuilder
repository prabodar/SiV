json.array!(@localvdos) do |localvdo|
  json.extract! localvdo, :id, :url
  json.url localvdo_url(localvdo, format: :json)
end
