class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.integer :owner
      t.string :filename
      t.string :content_type
      t.binary :file_contents
      t.string :type_research

      t.timestamps null: false
    end
  end
end
