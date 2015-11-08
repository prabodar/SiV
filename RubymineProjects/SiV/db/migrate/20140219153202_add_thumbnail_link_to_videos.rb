class AddThumbnailLinkToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :thumbnail_link, :string
  end
end
