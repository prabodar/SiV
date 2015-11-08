class AddUserToLocalvdo < ActiveRecord::Migration
  def change
    add_reference :localvdos, :user, index: true
  end
end
