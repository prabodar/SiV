class AddFacebookVidToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :facebook_vid, :string
  end
end
