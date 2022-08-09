class AddIsExpenseToEntry < ActiveRecord::Migration[5.2]
  def change
    add_column :entries, :is_expense, :boolean
  end
end
