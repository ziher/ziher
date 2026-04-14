class CreateKsefInvoices < ActiveRecord::Migration[8.0]
  def change
    create_table :ksef_invoices do |t|
      t.string :ksef_number, null: false
      t.string :invoice_number
      t.date :issue_date, null: false
      t.string :seller_nip
      t.string :seller_name
      t.string :buyer_nip
      t.decimal :net_amount, precision: 12, scale: 2
      t.decimal :gross_amount, precision: 12, scale: 2
      t.string :currency, default: "PLN"
      t.text :invoice_xml
      t.jsonb :metadata, default: {}, null: false

      t.integer :status, null: false, default: 0
      t.references :unit, foreign_key: { on_delete: :nullify }, null: true
      t.references :assigned_by, foreign_key: { to_table: :users, on_delete: :nullify }, null: true
      t.datetime :assigned_at
      t.text :note
      t.references :imported_entry, foreign_key: { to_table: :entries, on_delete: :nullify }, null: true

      t.datetime :synced_at, null: false
      t.timestamps
    end

    add_index :ksef_invoices, :ksef_number, unique: true
    add_index :ksef_invoices, [:unit_id, :status]
    add_index :ksef_invoices, :issue_date
    add_index :ksef_invoices, :synced_at
  end
end
