class ReportsController < ApplicationController

  INITIAL_BALANCE_KEY = "initial_balance"
  TOTAL_BALANCE_INCOME_KEY="total_balance_income"
  TOTAL_BALANCE_EXPENSE_KEY="total_balance_expense"

  def all_finance_one_percent
    unless current_user.is_superadmin
      redirect_to root_path, alert: I18n.t(:default, :scope => :unauthorized)
      return
    end

    @report_header = "Administracja > Całościowy raport finansowy dla 1%"
    @report_link = all_finance_one_percent_report_path

    create_hashes_for(:amount_one_percent, :initial_balance_one_percent)

    render 'report_template'

  end

  def all_finance
    unless current_user.is_superadmin
      redirect_to root_path, alert: I18n.t(:default, :scope => :unauthorized)
      return
    end

    @report_header = "Administracja > Całościowy raport finansowy"
    @report_link = all_finance_report_path

    create_hashes_for(:amount, :initial_balance)

    render 'report_template'
  end

  private

  def create_hashes_for(amount_type, initial_balance_type)
    @selected_year = params[:year] || session[:current_year]

    @years = Journal.find_all_years
    @categories = Category.where(:year => @selected_year)

    @initial_balance_key = INITIAL_BALANCE_KEY
    @total_balance_income_key = TOTAL_BALANCE_INCOME_KEY
    @total_balance_expense_key = TOTAL_BALANCE_EXPENSE_KEY


    @finance_hash = create_hash_for_amount_type(JournalType::FINANCE_TYPE_ID,
                                                @selected_year,
                                                amount_type,
                                                initial_balance_type)

    @bank_hash = create_hash_for_amount_type(JournalType::BANK_TYPE_ID,
                                             @selected_year,
                                             amount_type,
                                             initial_balance_type)

    @total_hash = get_totals(@finance_hash, @bank_hash)
  end

  def create_hash_for_amount_type(journal_type, year, amount_type, initial_balance_type)
    hash = get_categories_hash(journal_type, year, amount_type)

    hash.merge!(get_initial_balances(journal_type, year, initial_balance_type))

    hash.merge!(get_total_balances(hash, year))

    return hash
  end

  def get_totals(finance_hash, bank_hash)
    hash = Hash.new

    income = finance_hash[TOTAL_BALANCE_INCOME_KEY] + bank_hash[TOTAL_BALANCE_INCOME_KEY]
    expense = finance_hash[TOTAL_BALANCE_EXPENSE_KEY] + bank_hash[TOTAL_BALANCE_EXPENSE_KEY]

    hash[:income] = income
    hash[:expense] = expense

    finance_sum = finance_hash[TOTAL_BALANCE_INCOME_KEY] - finance_hash[TOTAL_BALANCE_EXPENSE_KEY]
    bank_sum = bank_hash[TOTAL_BALANCE_INCOME_KEY] - bank_hash[TOTAL_BALANCE_EXPENSE_KEY]

    hash[:finance_sum] = finance_sum
    hash[:bank_sum] = bank_sum

    sum = income - expense

    hash[:sum] = sum

    return hash
  end

  def get_total_balances(account_hash, year)
    hash = Hash.new

    categories = Category.where(:year => year)

    income = 0
    expense = 0

    categories.each do |category|
      if category.is_expense then
        expense += account_hash[category.id]
      else
        income += account_hash[category.id]
      end
    end

    income += account_hash[INITIAL_BALANCE_KEY]

    hash[TOTAL_BALANCE_INCOME_KEY] = income
    hash[TOTAL_BALANCE_EXPENSE_KEY] = expense

    return hash
  end

  def get_initial_balances(journal_type, year, balance_type)
    hash = Hash.new

    sum = Journal.where(:year => year, :journal_type => journal_type).sum(balance_type)

    hash[INITIAL_BALANCE_KEY] = sum

    return hash
  end

  def get_categories_hash(journal_type, year, amount_type)
    hash = Hash.new

    categories = Category.where(:year => year)
    journals = Journal.where(:year => year, :journal_type => journal_type)
    entries = Entry.where(:journal => journals)

    categories.each do |category|
      items = Item.where(:category => category, :entry => entries)

      sum = items.sum(amount_type)

      hash[category.id] = sum
    end

    return hash
  end
end
