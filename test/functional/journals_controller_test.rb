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
    expected_message = I18n.t(:sum_one_percent_negative_with_one_percent_left, :sum_one_percent => sum_one_percent, :sum => sum, :scope => :journal)
    assert_equal expected_message, flash[:alert]
  end

  test "should show journal with sorted by date entries" do
    # TODO
  end

end
