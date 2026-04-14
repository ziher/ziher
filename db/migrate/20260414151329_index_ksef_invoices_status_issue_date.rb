class IndexKsefInvoicesStatusIssueDate < ActiveRecord::Migration[8.0]
  def change
    add_index :ksef_invoices, [:status, :issue_date]
  end
end
