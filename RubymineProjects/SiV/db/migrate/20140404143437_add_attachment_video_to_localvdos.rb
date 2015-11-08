class AddAttachmentVideoToLocalvdos < ActiveRecord::Migration
  def self.up
    change_table :localvdos do |t|
      t.attachment :video
    end
  end

  def self.down
    drop_attached_file :localvdos, :video
  end
end
