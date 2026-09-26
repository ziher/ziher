require 'test_helper'

class EntriesControllerTest < ActionDispatch::IntegrationTest
  include ActionView::Helpers::NumberHelper

  setup do
    sign_in users(:master_1zgm)
    @entry = entries(:expense_one)
    @entry_income = entries(:income_one)
  end

  test "should get new" do
    # get :new, params: {journal_id: @entry.journal_id}
    get new_entry_path, params: {journal_id: @entry.journal_id}
    assert_response :success
  end

  test "should create entry" do
    assert_difference('Entry.count') do

      new_hash = @entry.attributes
      items_hash = Hash.new
      i = 0
      @entry.items.each do |item|
        items_hash[i.to_s] = item.attributes
        items_hash[i.to_s]["id"] = nil
        i += 1
      end
      new_hash["items_attributes"] = items_hash
      new_hash["id"] = nil

      post entries_url, params: {entry: new_hash}
    end

    # po dodaniu wpisu nie wracamy do (wolno ładującej się) książki,
    # tylko pokazujemy stronę potwierdzenia z opcjami kolejnych akcji
    assert_redirected_to entry_path(Entry.last)
    assert_equal 'Wpis dodany', flash[:notice]

    follow_redirect!
    assert_response :success
    assert_select "a[href=?]", new_entry_path(journal_id: @entry.journal_id, is_expense: false), text: /Dodaj nowy wpływ/
    assert_select "a[href=?]", new_entry_path(journal_id: @entry.journal_id, is_expense: true), text: /Dodaj nowy wydatek/
    assert_select "a[href=?]", journal_path(@entry.journal), text: /Wyświetl książkę/
  end

  test "should show all possible categories when editing existing expense entry" do
    get edit_entry_path(@entry)
    assert_select "input.category", Category.where(:year => @entry.journal.year, :is_expense => @entry.is_expense).count * 2
    #przenoszenie kwot miedzy ksiazkami na razie wstrzymane
    #+ Category.where(:year => @entry.journal.year, :is_expense => !@entry.is_expense).count
    Category.where(:year => @entry.journal.year, :is_expense => @entry.is_expense).each do |category|
      assert_select "input.category_id[value='#{category.id}']", true
    end
  end

  test "should show all possible categories when editing existing income entry" do
    get edit_entry_path(@entry_income)
    assert_select "input.category", Category.where(:year => @entry_income.journal.year, :is_expense => @entry_income.is_expense).count
    Category.where(:year => @entry_income.journal.year, :is_expense => @entry_income.is_expense).each do |category|
      assert_select "input.category_id[value='#{category.id}']", true
    end
  end

  test "should not show categories from different years" do
    get edit_entry_path(@entry)
    Category.where('year <> ?', @entry.journal.year).each do |category|
      assert_select "input.category_id[value='#{category.id}']", false
    end
  end

  test "should not show duplicate categories when editing existing expense entry" do
    get edit_entry_path(@entry)
    put entry_url(@entry), params: {entry: {name: "updated"}}
    get edit_entry_path(@entry)
    assert_select "input.category", Category.where(:year => @entry.journal.year, :is_expense => @entry.is_expense).count * 2
    #przenoszenie kwot miedzy ksiazkami na razie wstrzymane
    #+ Category.where(:year => @entry.journal.year, :is_expense => !@entry.is_expense).count
  end

  test "should not show duplicate categories when editing existing income entry" do
    get edit_entry_path(@entry_income)
    put entry_url(@entry_income), params: {entry: {name: "updated"}}
    get edit_entry_path(@entry_income)
    assert_select "input.category", Category.where(:year => @entry_income.journal.year, :is_expense => @entry_income.is_expense).count
  end

  test "should show entry" do
    get entry_path(@entry)
    assert_response :success
  end

  test "should show one percent and grant amounts for expense entry" do
    grant = grants(:one)
    grant.create_income_category_for_year(@entry.journal.year)

    get entry_path(@entry)
    assert_response :success

    assert_select "label", text: "w tym 1,5%"
    assert_select "label", text: "w tym #{grant.name}"

    Category.where(:year => @entry.journal.year, :is_expense => true).each do |category|
      assert_select "label", text: category.name
    end

    # expense_one: dwie pozycje po 9.99 z 1,5% = 9.99 każda
    one_percent_sum = @entry.items.sum { |item| item.amount_one_percent || 0 }
    assert_select "input#total-sum[value=?]", number_with_precision(@entry.sum, precision: 2)
    assert_select "input#total-sum-one-percent[value=?]", number_with_precision(one_percent_sum, precision: 2)
    assert_select "input#total-sum-grant-#{grant.id}[value=?]", number_with_precision(@entry.get_sum_for_grant(grant), precision: 2)
  end

  test "should not show one percent and grant columns for income entry" do
    grants(:one).create_income_category_for_year(@entry_income.journal.year)

    get entry_path(@entry_income)
    assert_response :success

    assert_select "label", text: /^w tym /, count: 0
    assert_select "input#total-sum-one-percent", count: 0
  end

  test "should get edit" do
    get edit_entry_path(@entry)
    assert_response :success
  end

  test "should edit items when editing entry" do
    get edit_entry_path(@entry)
    assert_select "input.category"
  end

  test "should update entry" do
    put entry_url(@entry), params: {entry: {name: "updated"}}
    assert_redirected_to entry_path(@entry)
    assert_equal 'Zmiany zapisane', flash[:notice]

    follow_redirect!
    assert_response :success
    assert_select "a[href=?]", new_entry_path(journal_id: @entry.journal_id, is_expense: false), text: /Dodaj nowy wpływ/
    assert_select "a[href=?]", new_entry_path(journal_id: @entry.journal_id, is_expense: true), text: /Dodaj nowy wydatek/
    assert_select "a[href=?]", journal_path(@entry.journal), text: /Wyświetl książkę/
  end

  test "should destroy entry" do
    assert_difference('Entry.count', -1) do
      delete entry_path(@entry)
    end

    assert_redirected_to journal_path(@entry.journal)
  end


  test 'should not save empty entry' do
    # given
    entries_count_before = Entry.count
    empty_entry = copy_to_new_hash(@entry)
    reset_amounts(empty_entry)

    # when
    post entries_url, params: {entry: empty_entry}

    #then
    entries_count_after = Entry.count
    assert_equal(entries_count_before, entries_count_after)
  end

  test "should delete items associated with entry" do
    items_count = @entry.items.count
    assert_difference('Item.count', items_count * -1) do
      delete entry_path(@entry)
    end
  end

  test "should create expense entry with grant amounts" do
    grant = grants(:one)
    grant.create_income_category_for_year(@entry.journal.year)

    assert_difference(['Entry.count', 'ItemGrant.count'], 1) do
      post entries_url, params: {entry: new_expense_params(grant, date: @entry.date.to_s)}
    end

    entry = Entry.last
    assert_redirected_to entry_path(entry)
    assert_equal 3, entry.get_sum_for_grant(grant)
    assert_equal 3, entry.get_amount_for_category_and_grant(categories(:five), grant)
  end

  test "should keep typed grant amounts when creating expense entry fails validation" do
    grant = grants(:one)
    grant.create_income_category_for_year(@entry.journal.year)

    get new_entry_path, params: {journal_id: @entry.journal_id, is_expense: true}
    assert_response :success
    categories_order_on_new = css_select("input.category_id").map { |input| input["value"] }

    assert_no_difference(['Entry.count', 'ItemGrant.count']) do
      # brak daty -> walidacja nie przechodzi, formularz jest wyświetlany ponownie
      post entries_url, params: {entry: new_expense_params(grant, date: "")}
    end
    assert_response :unprocessable_entity

    # kwota, 1,5% oraz kwota dotacji wpisane przez użytkownika są nadal w formularzu
    assert_select "input.amount-input[value='10']"
    assert_select "input.amount-input-one-percent[value='2']"
    assert_select "input.amount-input-grants.grant-#{grant.id}[value='3']"
    # dotacja wpisana jako 0 nie jest pokazywana (0 = usunięcie dotacji)
    assert_select "input.amount-input-grants.grant-#{grant.id}[value='0']", count: 0
    assert_select "input.amount-input-grants.grant-#{grant.id}[value='0.0']", count: 0
    # nowy wpis - żadna z dotacji nie ma jeszcze id
    assert_select "input[name$='[item_grants_attributes][0][id]'][value='']", css_select("input.amount-input-grants").size

    # wszystkie kategorie, w tej samej kolejności co na stronie nowego wpisu
    assert_equal categories_order_on_new, css_select("input.category_id").map { |input| input["value"] }
  end

  test "should keep typed grant amounts when updating expense entry fails validation" do
    grant = grants(:one)
    grant.create_income_category_for_year(@entry.journal.year)

    # fixtures mają zduplikowane dotacje dla pozycji :one - zostawiamy po jednej na dotację
    item_grants(:two).destroy
    item_grants(:four).destroy
    item = items(:one)
    item_grant = item_grants(:one)
    stored_amount = item_grant.amount

    # pusty opis -> walidacja nie przechodzi, formularz jest wyświetlany ponownie
    put entry_url(@entry), params: {entry: {name: "", items_attributes: {
      "0" => {id: item.id, amount: 100, amount_one_percent: 10,
              item_grants_attributes: {"0" => {id: item_grant.id, grant_id: grant.id, amount: 4}}}}}}
    assert_response :unprocessable_entity

    # formularz pokazuje właśnie wpisaną kwotę dotacji, a nie tę z bazy
    assert_select "input.amount-input-grants.grant-#{grant.id}[value='4']"
    assert_select "input.amount-input-grants.grant-#{grant.id}[value='#{stored_amount}']", count: 0
    # ... i nadal wskazuje na istniejący rekord dotacji, żeby ponowny zapis go zaktualizował
    assert_select "input[name$='[item_grants_attributes][0][id]'][value='#{item_grant.id}']"

    # w bazie nic się nie zmieniło
    assert_equal stored_amount, item_grant.reload.amount
    assert_equal "EntryOne", @entry.reload.name
  end

  test "should not show removed grant amount when updating expense entry fails validation" do
    grant = grants(:one)
    grant.create_income_category_for_year(@entry.journal.year)

    item_grants(:two).destroy
    item_grants(:four).destroy
    item = items(:one)
    item_grant = item_grants(:one)

    # dotacja wyzerowana w formularzu (= do usunięcia) + pusty opis
    put entry_url(@entry), params: {entry: {name: "", items_attributes: {
      "0" => {id: item.id, amount: 100, amount_one_percent: 10,
              item_grants_attributes: {"0" => {id: item_grant.id, grant_id: grant.id, amount: 0}}}}}}
    assert_response :unprocessable_entity

    assert_select "input.amount-input-grants.grant-#{grant.id}[value='']", css_select("input.amount-input-grants.grant-#{grant.id}").size
    assert_select "input[name$='[item_grants_attributes][0][id]'][value='#{item_grant.id}']"
    assert ItemGrant.exists?(item_grant.id), "failed update must not remove the grant from the database"
  end

  # Wydatek z dwiema pozycjami: 10 (w tym 1,5%: 2, dotacja: 3) i 5 (dotacja wpisana jako 0)
  def new_expense_params(grant, date:)
    {date: date, name: "Wydatek z dotacją", document_number: "FV 1/2012", journal_id: @entry.journal_id, is_expense: true,
     items_attributes: {
       "0" => {category_id: categories(:five).id, amount: 10, amount_one_percent: 2,
               item_grants_attributes: {"0" => {grant_id: grant.id, amount: 3}}},
       "1" => {category_id: categories(:six).id, amount: 5,
               item_grants_attributes: {"0" => {grant_id: grant.id, amount: 0}}}}}
  end

  def copy_to_new_hash(entry)
    new_hash = entry.attributes
    items_hash = Hash.new
    i = 0
    entry.items.each do |item|
      items_hash[i.to_s] = item.attributes
      items_hash[i.to_s]['id'] = nil
      i += 1
    end
    new_hash['items_attributes'] = items_hash
    new_hash['id'] = nil
    new_hash
  end

  def reset_amounts(entry)
    (0 .. entry['items_attributes'].length - 1).each {|i|
      entry['items_attributes'][i.to_s]['amount'] = 0
    }
  end
end
