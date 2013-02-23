class AddIsExpenseToEntry < ActiveRecord::Migration
  def change
    add_column :entries, :is_expense, :boolean
  end
end
