class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.string :name
      t.string :uid
      t.string :link
      t.boolean :inLocal

      t.timestamps
    end
  end
end
