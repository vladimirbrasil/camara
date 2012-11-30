class CreateSenadors < ActiveRecord::Migration
  def change
    create_table :senadors do |t|
      t.string :nome
      t.string :email
      t.string :facebook
      t.string :twitter
      t.integer :uri_id

      t.timestamps
    end
    add_index :senadors, [:uri_id]    
  end
end
