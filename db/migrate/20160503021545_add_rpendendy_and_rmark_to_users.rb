class AddRpendendyAndRmarkToUsers < ActiveRecord::Migration
  def change
    add_column :users, :rpen, :boolean
    add_column :users, :rmark, :boolean
  end
end
