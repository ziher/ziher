# encoding: utf-8
include ActionView::Helpers::NumberHelper

require 'test_helper'

class JournalsControllerTest < ActionController::TestCase
  setup do
    sign_in users(:scoutmaster_dukt)
    @journal = journals(:finance_2012)
    @new_journal = Journal.new(:journal_type => journal_types(:finance), :year => 2014, :unit => units(:dukt))
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:journals)
  end

  test "index should redirect to journal" do
    journal_2011 = journals(:finance_2011)
    get :index, {:unit_id => journal_2011.unit.id, :journal_type_id => journal_2011.journal_type.id, :year => journal_2011.year}
    assert_redirected_to journal_2011
  end

  test "index should create journal if it doesnt exist" do
    assert_difference('Journal.count') do
      get :index, {:unit_id => @new_journal.unit.id, :journal_type_id => @new_journal.journal_type_id, :year => @new_journal.year}
    end
    assert_redirected_to Journal.last
  end

  test "should show dashes for empty items when showing all entries" do
    get :show, id: @journal.to_param
    assert_select "td.income", "-"
    assert_select "td.expense", "-"
  end

  test "scoutmaster cannot create journals" do
    get :new
    assert_unauthorized

    post :create, journal: @new_journal.attributes
    assert_unauthorized
  end

  test "should show journal" do
    get :show, id: @journal.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @journal.to_param
    assert_response :success
  end

  test "scoutmaster cannot destroy journals" do
    delete :destroy, id: @journal.to_param

    assert_unauthorized
  end

  test "should show initial balance" do
    get :show, id: @journal.to_param
    assert_select "#initial-balance", /#{number_with_precision(@journal.initial_balance, :precision => 2)} zł/
    assert_select "#initial-balance", /(#{number_with_precision(@journal.initial_balance_one_percent, :precision => 2)} zł)/
  end

  test "should not have access to journal" do
    get :show, id: journals(:two2012f)
    assert_unauthorized
  end
end
