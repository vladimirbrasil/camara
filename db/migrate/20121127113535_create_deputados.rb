class CreateDeputados < ActiveRecord::Migration
  def change
    create_table :deputados do |t|
      t.string :nome
      t.string :email
      t.string :facebook
      t.integer :uri_id

      t.timestamps
    end
    add_index :deputados, [:uri_id]    
  end
end
