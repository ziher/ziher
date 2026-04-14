require 'test_helper'

class Ksef::ParserTest < ActiveSupport::TestCase
  def setup
    @xml = File.read(Rails.root.join("test/fixtures/files/ksef/sample_fa3.xml"))
  end

  test "extracts top-level invoice fields" do
    attrs = Ksef::Parser.parse(@xml)

    assert_equal "9876543210", attrs[:seller_nip]
    assert_equal "Sprzedawca SP. Z O.O.", attrs[:seller_name]
    assert_equal "1234567890", attrs[:buyer_nip]
    assert_equal "FV/2026/03/0123", attrs[:invoice_number]
    assert_equal Date.new(2026, 3, 15), attrs[:issue_date]
    assert_equal BigDecimal("100.00"), attrs[:net_amount]
    assert_equal BigDecimal("123.00"), attrs[:gross_amount]
    assert_equal "PLN", attrs[:currency]
  end

  test "captures line items in metadata" do
    attrs = Ksef::Parser.parse(@xml)
    lines = attrs.dig(:metadata, "lines")
    assert_equal 1, lines.size
    assert_equal "Usługa szkoleniowa", lines.first["name"]
    assert_equal "100.00", lines.first["net"]
    assert_equal "23", lines.first["vat"]
  end
end
