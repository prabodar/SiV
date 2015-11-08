class CreateLocalvdos < ActiveRecord::Migration
  def change
    create_table :localvdos do |t|
      t.string :url

      t.timestamps
    end
  end
end
