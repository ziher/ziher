module JournalsHelper
  def print_formatted_amount(amount)
    concat (amount == 0) ? "-" : number_with_precision(amount, :precision => 2).to_s
  end

  def print_formatted_amount_with_one_percent(amount, amount_one_percent)
    if amount == 0
        result = "-"
    else
      result = "" + number_with_precision(amount, :precision => 2).to_s

      result += "<br/><small><span title='" + I18n.t('helpers.label.journal.one_percent_tooltip')  + "' class='muted'>"
      if amount_one_percent != 0
        result += number_with_precision(amount_one_percent, :precision => 2).to_s
      end
      result += "</span></small>"
    end

    concat result.html_safe
  end
end
