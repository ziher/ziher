class AddCodeToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :code, :string
  end
end
