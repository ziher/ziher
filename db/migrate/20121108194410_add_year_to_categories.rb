class AddYearToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :year, :integer
  end
end
