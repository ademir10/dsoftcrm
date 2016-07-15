class AddRsalesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :rsales, :boolean
  end
end
