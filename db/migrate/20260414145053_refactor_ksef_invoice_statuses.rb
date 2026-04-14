class RefactorKsefInvoiceStatuses < ActiveRecord::Migration[8.0]
  # Old enum: { unassigned: 0, to_clarify: 1, imported: 2, dismissed: 3 }
  # New enum: { pending: 0, unassigned: 1, assigned: 2, imported: 3, dismissed: 4 }
  #
  # Mapping (old -> new):
  #   (0, nil)     -> pending     (0) — freshly synced, unreviewed
  #   (0, unit)    -> assigned    (2)
  #   (1, nil)     -> unassigned  (1) — in the claim pool
  #   (1, unit)    -> assigned    (2)
  #   (2, *)       -> imported    (3)
  #   (3, *)       -> dismissed   (4)
  def up
    # Move highest values first to avoid collisions.
    execute "UPDATE ksef_invoices SET status = 4 WHERE status = 3"
    execute "UPDATE ksef_invoices SET status = 3 WHERE status = 2"
    execute "UPDATE ksef_invoices SET status = 2 WHERE status IN (0, 1) AND unit_id IS NOT NULL"
    # status=0 with no unit stays 0 (now pending)
    # status=1 with no unit stays 1 (now unassigned)
  end

  def down
    execute "UPDATE ksef_invoices SET status = 3 WHERE status = 4"
    execute "UPDATE ksef_invoices SET status = 2 WHERE status = 3"
    execute "UPDATE ksef_invoices SET status = 1 WHERE status = 2"
    execute "UPDATE ksef_invoices SET status = 0 WHERE status = 1"
    # status = 0 (pending) stays at 0, maps back to old unassigned
  end
end
