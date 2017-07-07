class ReportsController < ApplicationController

  def all_finance
    unless current_user.is_superadmin
      redirect_to root_path, alert: I18n.t(:default, :scope => :unauthorized)
      return
    end

    @initial_balance_key = "initial_balance"
    @total_balance_income_key = "total_balance_income"
    @total_balance_expense_key = "total_balance_outcome"

    @years = Journal.find_all_years
    @selected_year = params[:year] || session[:current_year]

    @categories = Category.where(:year => @selected_year)

    create_hashes_for(@selected_year, :amount, :initial_balance)

    respond_to do |format|
      format.html # all_finance.html.erb
    end
  end

  private

  def create_hashes_for(year, amount_type, initial_balance_type)
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

    income = finance_hash[@total_balance_income_key] + bank_hash[@total_balance_income_key]
    expense = finance_hash[@total_balance_expense_key] + bank_hash[@total_balance_expense_key]

    hash[:income] = income
    hash[:expense] = expense

    finance_sum = finance_hash[@total_balance_income_key] - finance_hash[@total_balance_expense_key]
    bank_sum = bank_hash[@total_balance_income_key] - bank_hash[@total_balance_expense_key]

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
        expense += account_hash[category.name]
      else
        income += account_hash[category.name]
      end
    end

    income += account_hash[@initial_balance_key]

    hash[@total_balance_income_key] = income
    hash[@total_balance_expense_key] = expense

    return hash
  end

  def get_initial_balances(journal_type, year, balance_type)
    hash = Hash.new

    sum = Journal.where(:year => year, :journal_type => journal_type).sum(balance_type)

    hash[@initial_balance_key] = sum

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

      hash[category.name] = sum
    end

    return hash
  end
end
