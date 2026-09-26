# encoding: utf-8
include ActionView::Helpers::NumberHelper

require 'test_helper'

class JournalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:master_1zgm)
    @journal = journals(:finance_2012)
    @new_journal = Journal.new(:journal_type => journal_types(:bank), :year => 2014, :unit => units(:troop_1zgm))
  end

  test "should get index" do
    get journals_path
    assert_response :redirect
    assert_redirected_to "/ksiazka_finansowa"
  end

  test "index should redirect to journal" do
    journal_2011 = journals(:finance_2011)
    get journals_url, params: {:unit_id => journal_2011.unit.id, :journal_type_id => journal_2011.journal_type.id, :year => journal_2011.year}
    assert_redirected_to journal_2011
  end

  test "index should create journal if it doesn't exist" do
    assert_difference('Journal.count') do
      get journals_url, params: {:unit_id => @new_journal.unit.id, :journal_type_id => @new_journal.journal_type_id, :year => @new_journal.year}
    end
    assert_redirected_to Journal.last
  end

  test "should show dashes for empty items when showing all entries" do
    get journal_path(@journal)
    assert_select "td.income", "-"
    assert_select "td.expense", "-"
  end

  test "should show journal" do
    get journal_path(@journal)
    assert_response :success
  end

  test "should show initial balance" do
    get journal_path(@journal)
    assert_select "#initial-balance", /#{number_with_precision(@journal.initial_balance, :precision => 2)} zł/
    assert_select "#initial-balance", /(#{number_with_precision(@journal.initial_balance_one_percent, :precision => 2)} zł)/
  end

  test "should not have access to journal" do
    get journal_path(journals(:two2012f))
    assert_unauthorized
  end

  test "should show alert for negative balance" do
    #given
    entry = entries(:expense_one)
    entry.items = [Item.create(:category => categories(:five), :amount => 200)]
    entry.save!
    sum_one_percent = @journal.get_final_balance_one_percent
    sum = @journal.get_final_balance

    #when
    get journal_path(@journal)

    #then
    expected_message = "Saldo końcowe (#{sum}) jest ujemne - proszę rozliczyć do zera środki z wszystkich dotacji (aktualnie #{sum_one_percent})"
    assert_equal expected_message, flash[:alert]
  end

  test "should show journal with sorted by date entries" do
    skip "not implemented"
  end

  test "should show one percent part of an expense entry in the expense sum column" do
    #given
    entry = entries(:expense_one)
    expected_sum = number_with_precision(entry.sum, :precision => 2)
    expected_one_percent = number_with_precision(entry.items.sum { |item| item.amount_one_percent || 0 }, :precision => 2)
    assert_not_equal "0.00", expected_one_percent

    #when
    get journal_path(@journal)

    #then
    assert_response :success
    # the cell of the entry row (not the "Suma" row) - it starts with the entry sum and lists its 1,5% part
    assert_select "td.expense_all", text: /\A#{Regexp.escape(expected_sum)}\s*1,5%:\s*#{Regexp.escape(expected_one_percent)}/
  end

  test "should export one percent part of an expense entry in csv" do
    #given
    entry = entries(:expense_one)
    expected_one_percent = number_with_precision(entry.items.sum { |item| item.amount_one_percent || 0 }, :precision => 2)
    assert_not_equal "0.00", expected_one_percent

    #when
    get journal_path(@journal, :format => :csv)

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
