class CreateMeessages < ActiveRecord::Migration
  def change
    create_table :meessages do |t|
      t.text :body
      t.references :conversation, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
