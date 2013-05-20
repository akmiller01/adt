class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text :content
      t.integer :project_id
      t.string :name
      t.string :email

      t.timestamps
    end
  end
end
