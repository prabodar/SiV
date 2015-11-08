class Localvdo < ActiveRecord::Base
  has_attached_file :video,
    :storage => :dropbox,
    :dropbox_credentials => Rails.root.join("config/dropbox.yml"),
    :dropbox_visibility => 'public'
  
  validates_attachment_content_type :video, :content_type => ["video/mp4", "video/mov", "video/avi"]
end


