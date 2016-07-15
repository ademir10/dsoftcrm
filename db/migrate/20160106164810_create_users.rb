class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :password_digest
      t.string :type_access
      t.boolean :ccategory
      t.boolean :cresearch
      t.boolean :cquestion
      t.boolean :cadvice
      t.boolean :cuser
      t.boolean :mupload
      t.boolean :rfecha
      t.boolean :minput
      t.boolean :mcli
      t.boolean :rbusiness
      t.boolean :ccli
      t.boolean :mmeeting
      t.boolean :ranalitic
      t.boolean :mlog
      t.decimal :goal
      t.integer :qnt_research
      t.decimal :total_sale
      t.decimal :current_percent
 
      t.timestamps null: false
    end
  end
end
