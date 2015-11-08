class AddLocalLinkToVideo < ActiveRecord::Migration
  def change
    add_column :videos, :local_link, :string
  end
end
