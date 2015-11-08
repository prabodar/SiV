class AddLogLastConnectionToUsers < ActiveRecord::Migration
  def change
    add_column :users, :log_last_connection, :text
  end
end
