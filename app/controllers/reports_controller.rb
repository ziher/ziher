class ReportsController < ApplicationController
  def all_finance
    unless current_user.is_superadmin
      redirect_to root_path, alert: I18n.t(:default, :scope => :unauthorized)
      return
    end

    year = "2013"

    journal_finance = 0
    journal_bank = 0

    @finance_hash = get_categories_hash(JournalType::FINANCE_TYPE_ID, year)
    @bank_hash = get_categories_hash(JournalType::BANK_TYPE_ID, year)

    @categories = Category.where(:year => year)



    respond_to do |format|
      format.html # all_finance.html.erb
    end
  end

  private

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
