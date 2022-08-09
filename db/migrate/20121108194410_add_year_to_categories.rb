class AddYearToCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :year, :integer
  end
end
