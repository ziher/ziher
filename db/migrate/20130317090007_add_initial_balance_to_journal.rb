class AddInitialBalanceToJournal < ActiveRecord::Migration
  def change
    add_column :journals, :initial_balance, :decimal, :null => false, :default => 0
  end
end
