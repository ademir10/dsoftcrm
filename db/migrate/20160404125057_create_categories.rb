class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :name
      t.string :link
      t.decimal :r1
      t.decimal :r2
      t.decimal :r3
      t.decimal :r4
      t.decimal :r5
      t.decimal :r6
      t.integer :qnt_question
      t.integer :position

      t.timestamps null: false
    end
  end
end
