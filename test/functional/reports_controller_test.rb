# encoding: utf-8
require 'test_helper'

class ReportsControllerTest < ActionDispatch::IntegrationTest
  include ActionView::Helpers::NumberHelper

  setup do
    sign_in users(:admin)
  end

  test "detailed all finance csv should export one percent part of an expense entry" do
    #given
    entry = entries(:expense_one)
    expected_one_percent = number_with_precision(entry.items.sum { |item| item.amount_one_percent || 0 }, :precision => 2)
    assert_not_equal "0.00", expected_one_percent

    #when
    get all_finance_detailed_report_path(:format => :csv, :year => entry.journal.year)

    #then
    assert_response :success
    rows = response.body.split("\n").map { |line| line.split("\t") }
    header = rows.first
    one_percent_column = header.index("Wydatki razem 1,5%")
    assert_not_nil one_percent_column, "csv header should contain 'Wydatki razem 1,5%' column: #{header.inspect}"

    entry_row = rows.find { |row| row[header.index("Opis")] == entry.name }
    assert_not_nil entry_row, "csv should contain a row for entry #{entry.name}"
    assert_equal expected_one_percent, entry_row[one_percent_column]
  end
end
