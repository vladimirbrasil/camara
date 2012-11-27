class AddTwitterToDeputados < ActiveRecord::Migration
  def change
    add_column :deputados, :twitter, :string
  end
end
