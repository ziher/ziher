module ReportsHelper
  def get_formatted_amount(amount, placeholder_for_zero = "0")
    return (amount == 0) ? placeholder_for_zero : number_with_precision(amount, :precision => 2).to_s
  end
end
