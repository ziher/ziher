class AddBlockedToToJournals < ActiveRecord::Migration[5.2]

  class Journal < ApplicationRecord
  end

  def change
    add_column :journals, :blocked_to, :date, null: true
  end
end
