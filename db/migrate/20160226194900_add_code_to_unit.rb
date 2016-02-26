class AddCodeToUnit < ActiveRecord::Migration
  def change
    add_column :units, :code, :string
    add_index :units, :code, :unique => true
  end
end
