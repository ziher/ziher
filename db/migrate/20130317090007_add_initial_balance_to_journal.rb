class AddInitialBalanceToJournal < ActiveRecord::Migration
  def change
    add_column :journals, :initial_balance, :decimal, :null => false, :default => 0, :precision => 9, :scale => 2
  end
end
