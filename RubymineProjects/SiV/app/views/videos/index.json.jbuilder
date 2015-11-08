json.array!(@videos) do |video|
  json.extract! video, :id, :name, :uid, :facebook_vid, :link, :inLocal
  json.url video_url(video, format: :json)
end
