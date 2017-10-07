class ChangeDecimalToMoney < ActiveRecord::Migration
  def change
    change_column :inventory_entries, :total_value, :money
    change_column :items, :amount, :money
    change_column :items, :amount_one_percent, :money
    change_column :journals, :initial_balance, :money
    change_column :journals, :initial_balance_one_percent, :money
  end
end
