class CreateMeetings < ActiveRecord::Migration
  def change
    create_table :meetings do |t|
      t.string :client
      t.string :phone
      t.decimal :cotation_value
      t.string :status
      t.string :type_client
      t.date :start_time
      t.integer :clerk_id
      t.string :research_path
      t.integer :research_id
      t.string :obs
      t.string :clerk_name
      

      t.timestamps null: false
    end
  end
end
