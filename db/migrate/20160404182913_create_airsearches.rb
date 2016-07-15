class CreateAirsearches < ActiveRecord::Migration
  def change
    create_table :airsearches do |t|
      t.string :user
      t.string :client
      t.string :type_client
      t.string :phone
      t.integer :q1
      t.integer :q2
      t.integer :q3
      t.integer :q4
      t.integer :q5
      t.integer :q6
      t.integer :q7
      t.integer :q8
      t.integer :q9
      t.integer :q10
      t.integer :q11
      t.integer :q12
      t.decimal :cotation_value
      t.string :status
      t.string :reason
      t.string :pains
      t.string :solution_applied
      t.string :schedule
      t.string :obs
      t.string :finished
      t.references :user, index: true, foreign_key: true
          
      t.timestamps null: false
    end
  end
end
