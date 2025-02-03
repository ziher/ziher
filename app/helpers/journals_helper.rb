module JournalsHelper
  def get_formatted_amount(amount, placeholder_for_zero = "0")
    return (amount == 0) ? placeholder_for_zero : number_with_precision(amount, :precision => 2).to_s
  end

  def print_formatted_amount(amount)
    concat get_formatted_amount(amount, "-")
  end

  def print_formatted_amount_with_one_percent(category_name, amount, amount_one_percent)
    if amount == 0
        result = "-"
    else
      result = "" + number_with_precision(amount, :precision => 2).to_s

      result += "<br/><small><span title='" + category_name + "&#013;" + I18n.t('helpers.label.journal.one_percent_tooltip')  + "' class='text-muted'>"
      if amount_one_percent != 0
        result += number_with_precision(amount_one_percent, :precision => 2).to_s
      end
      result += "</span></small>"
    end

    concat result.html_safe
  end

  def print_formatted_journal_sums_with_grants(category_name, journal)
    if journal.get_expense_sum == 0
      result = "-"
  else
    result = "" + number_with_precision(journal.get_expense_sum, :precision => 2).to_s

    if journal.get_expense_sum_one_percent != 0

      amount_string = number_with_precision(journal.get_expense_sum_one_percent, :precision => 2).to_s

      result += "<br/><small><small><span title='" + category_name + "&#013;" + I18n.t('helpers.label.journal.one_percent_tooltip')  + ": " + amount_string + "' class='text-muted'>1%: "
      result += amount_string
      result += "</span></small></small>"
    end

    @grants_by_journal_year.each do |grant|
      grant_amount = journal.get_expense_sum_for_grant(grant)
      if grant_amount != nil && grant_amount != 0
        grant_and_amount = grant.name + ": " + number_with_precision(grant_amount, precision: 2).to_s

        result += "<br/><small><small><span title='" + category_name + "&#013;Środki wydane z " + grant_and_amount  + "' class='text-muted'>"
        result += grant_and_amount
        result += "</span></small></small>"
      end
    end
  end

  concat result.html_safe
  end

  def print_formatted_entry_sum_with_grants(category_name, entry)
    if entry.sum == 0
        result = "-"
    else
      result = "" + number_with_precision(entry.sum, :precision => 2).to_s

      if entry.sum_one_percent != 0

        amount_string = number_with_precision(entry.sum_one_percent, :precision => 2).to_s

        result += "<br/><small><small><span title='" + category_name + "&#013;" + I18n.t('helpers.label.journal.one_percent_tooltip')  + ": " + amount_string + "' class='text-muted'>1%: "
        result += amount_string
        result += "</span></small></small>"
      end

      @grants_by_journal_year.each do |grant|
        grant_amount = entry.get_sum_for_grant(grant)
        if grant_amount != nil && grant_amount != 0
          grant_and_amount = grant.name + ": " + number_with_precision(grant_amount, precision: 2).to_s

          result += "<br/><small><small><span title='" + category_name + "&#013;Środki wydane z " + grant_and_amount  + "' class='text-muted'>"
          result += grant_and_amount
          result += "</span></small></small>"
        end
      end
    end

    concat result.html_safe
  end

  def print_formatted_amount_with_grant(category, amount, amount_one_percent, grants = nil, entry = nil)
    if amount == 0
      result = "-"
    else
      result = "" + number_with_precision(amount, :precision => 2).to_s

      if amount_one_percent != 0

        amount_string = number_with_precision(amount_one_percent, :precision => 2).to_s

        result += "<br/><small><small><span title='" + category.name + "&#013;" + I18n.t('helpers.label.journal.one_percent_tooltip')  + ": " + amount_string + "' class='text-muted'>1%: "
        result += amount_string
        result += "</span></small></small>"
      end

      if ! grants.blank?
        grants.each do |grant|

          grant_amount = entry.get_amount_for_category_and_grant(category, grant)
          if grant_amount != nil && grant_amount != 0
            grant_and_amount = grant.name + ": " + number_with_precision(grant_amount, precision: 2).to_s

            result += "<br/><small><small><span title='" + category.name + "&#013;Środki wydane z " + grant_and_amount  + "' class='text-muted'>"
            result += grant_and_amount
            result += "</span></small></small>"
          end
        end
      end
    end

    concat result.html_safe
  end

  def print_formatted_journal_sums_for_categories_with_grants(category, journal)
    journal_sum_for_category = journal.get_sum_for_category(category)

    if journal_sum_for_category == 0
      result = "-"
    else
      result = "" + number_with_precision(journal_sum_for_category, :precision => 2).to_s

      journal_sum_one_percent_for_category = journal.get_sum_one_percent_for_category(category)

      if journal_sum_one_percent_for_category != 0

        amount_string = number_with_precision(journal_sum_one_percent_for_category, :precision => 2).to_s

        result += "<br/><small><small><span title='" + category.name + "&#013;" + I18n.t('helpers.label.journal.one_percent_tooltip')  + ": " + amount_string + "' class='text-muted'>1%: "
        result += amount_string
        result += "</span></small></small>"
      end

      @grants_by_journal_year.each do |grant|
        grant_amount = journal.get_sum_for_grant_in_category(grant, category)
        if grant_amount != nil && grant_amount != 0
          grant_and_amount = grant.name + ": " + number_with_precision(grant_amount, precision: 2).to_s

          result += "<br/><small><small><span title='" + category.name + "&#013;Środki wydane z " + grant_and_amount  + "' class='text-muted'>"
          result += grant_and_amount
          result += "</span></small></small>"
        end
      end
    end

    concat result.html_safe
  end
end
