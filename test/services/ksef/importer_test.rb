require 'test_helper'

class Ksef::ImporterTest < ActiveSupport::TestCase
  def base_invoice_attrs(overrides = {})
    {
      ksef_number: "X-100",
      invoice_number: "FV/100",
      issue_date: Date.new(2012, 6, 1),
      seller_name: "Sprzedawca",
      gross_amount: 250.00,
      synced_at: Time.current,
      status: :assigned
    }.merge(overrides)
  end

  test "creates an Entry with one Item from a KsefInvoice" do
    user = users(:master_1zgm)
    journal = journals(:finance_2012)
    category = categories(:two)

    invoice = KsefInvoice.create!(base_invoice_attrs(unit_id: journal.unit_id))

    entry = Ksef::Importer.call(invoice: invoice, journal: journal, category: category, user: user)

    assert entry.persisted?
    assert_equal "Sprzedawca", entry.name
    assert_equal "FV/100", entry.document_number
    assert_equal Date.new(2012, 6, 1), entry.date
    assert entry.is_expense
    assert_equal 1, entry.items.size
    assert_in_delta 250.00, entry.items.first.amount.to_f, 0.001
    assert_equal category, entry.items.first.category

    invoice.reload
    assert invoice.imported?
    assert_equal entry.id, invoice.imported_entry_id
  end

  test "raises when invoice is already imported" do
    user = users(:master_1zgm)
    journal = journals(:finance_2012)
    category = categories(:two)

    invoice = KsefInvoice.create!(base_invoice_attrs(ksef_number: "X-200", unit_id: journal.unit_id, status: :imported))

    assert_raises(Ksef::Importer::InvalidImport) do
      Ksef::Importer.call(invoice: invoice, journal: journal, category: category, user: user)
    end
  end

  test "raises when invoice has no unit" do
    user = users(:master_1zgm)
    journal = journals(:finance_2012)
    category = categories(:two)

    invoice = KsefInvoice.create!(base_invoice_attrs(ksef_number: "X-300", unit_id: nil))

    assert_raises(Ksef::Importer::InvalidImport) do
      Ksef::Importer.call(invoice: invoice, journal: journal, category: category, user: user)
    end
  end

  test "raises when journal unit does not match invoice unit" do
    user = users(:master_1zgm)
    journal = journals(:finance_2012) # unit: troop_1zgm
    other_unit = units(:troop_2zgm)
    category = categories(:two)

    invoice = KsefInvoice.create!(base_invoice_attrs(ksef_number: "X-400", unit_id: other_unit.id))

    assert_raises(Ksef::Importer::InvalidImport) do
      Ksef::Importer.call(invoice: invoice, journal: journal, category: category, user: user)
    end
  end
end
