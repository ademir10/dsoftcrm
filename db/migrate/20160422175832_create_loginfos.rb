class CreateLoginfos < ActiveRecord::Migration
  def change
    create_table :loginfos do |t|
      t.string :employee
      t.string :task

      t.timestamps null: false
    end
  end
end
