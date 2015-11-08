class AddOriginalUrlToLocalvdos < ActiveRecord::Migration
  def change
    add_column :localvdos, :originalURL, :string
  end
end
