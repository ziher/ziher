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

    @finance_hash = get_categories_hash(JournalType::FINANCE_TYPE_ID, @selected_year)
    @bank_hash = get_categories_hash(JournalType::BANK_TYPE_ID, @selected_year)

    @categories = Category.where(:year => @selected_year)

    @finance_hash.merge!(get_initial_balances(JournalType::FINANCE_TYPE_ID, @selected_year))
    @bank_hash.merge!(get_initial_balances(JournalType::BANK_TYPE_ID, @selected_year))

    @finance_hash.merge!(get_total_balances(@finance_hash, @selected_year))
    @bank_hash.merge!(get_total_balances(@bank_hash, @selected_year))

    @total_hash = get_totals()

    respond_to do |format|
      format.html # all_finance.html.erb
    end
  end

  private

  def get_totals()
    hash = Hash.new

    income = @finance_hash[@total_balance_income_key][0].to_d + @bank_hash[@total_balance_income_key][0].to_d
    income_one_percent = @finance_hash[@total_balance_income_key][1].to_d + @bank_hash[@total_balance_income_key][1].to_d

    expense = @finance_hash[@total_balance_expense_key][0].to_d + @bank_hash[@total_balance_expense_key][0].to_d
    expense_one_percent = @finance_hash[@total_balance_expense_key][1].to_d + @bank_hash[@total_balance_expense_key][1].to_d

    hash[:income] = income
    hash[:income_one_percent] = income_one_percent
    hash[:expense] = expense
    hash[:expense_one_percent] = expense_one_percent

    finance_sum = @finance_hash[@total_balance_income_key][0].to_d - @finance_hash[@total_balance_expense_key][0].to_d
    finance_sum_one_percent = @finance_hash[@total_balance_income_key][1].to_d - @finance_hash[@total_balance_expense_key][1].to_d
    bank_sum = @bank_hash[@total_balance_income_key][0].to_d - @bank_hash[@total_balance_expense_key][0].to_d
    bank_sum_one_percent = @bank_hash[@total_balance_income_key][1].to_d - @bank_hash[@total_balance_expense_key][1].to_d

    hash[:finance_sum] = finance_sum
    hash[:finance_sum_one_percent] = finance_sum_one_percent
    hash[:bank_sum] = bank_sum
    hash[:bank_sum_one_percent] = bank_sum_one_percent

    sum = income - expense
    sum_one_percent = income_one_percent - expense_one_percent

    hash[:sum] = sum
    hash[:sum_one_percent] = sum_one_percent

    return hash
  end

  def get_total_balances(account_hash, year)
    hash = Hash.new{|hsh,key| hsh[key] = [] }

    categories = Category.where(:year => year)

    income = 0
    income_one_percent = 0
    expense = 0
    expense_one_percent = 0

    categories.each do |category|
      if category.is_expense then
        expense += account_hash[category.name][0]
        expense_one_percent += account_hash[category.name][1]
      else
        income += account_hash[category.name][0]
        income_one_percent += account_hash[category.name][1]
      end
    end

    income += account_hash[@initial_balance_key][0]
    income_one_percent += account_hash[@initial_balance_key][1]

    hash[@total_balance_income_key].push income
    hash[@total_balance_income_key].push income_one_percent

    hash[@total_balance_expense_key].push expense
    hash[@total_balance_expense_key].push expense_one_percent

    return hash
  end

  def get_initial_balances(journal_type, year)
    hash = Hash.new{|hsh,key| hsh[key] = [] }

    balance = Journal.where(:year => year, :journal_type => journal_type).sum(:initial_balance)
    balance_one_percent = Journal.where(:year => year, :journal_type => journal_type).sum(:initial_balance_one_percent)

    hash[@initial_balance_key].push balance
    hash[@initial_balance_key].push balance_one_percent

    return hash
  end

  def get_categories_hash(journal_type, year)
    hash = Hash.new{|hsh,key| hsh[key] = [] }

    categories = Category.where(:year => year)
    journals = Journal.where(:year => year, :journal_type => journal_type)
    entries = Entry.where(:journal => journals)

    categories.each do |category|
      items = Item.where(:category => category, :entry => entries)

      amount_sum = items.sum(:amount)
      one_percent_sum = items.sum(:amount_one_percent)

      hash[category.name].push amount_sum
      hash[category.name].push one_percent_sum
    end

    return hash
  end
end
