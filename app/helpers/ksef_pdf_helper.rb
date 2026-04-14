module KsefPdfHelper
  def ksef_fmt_money(raw, currency = "PLN")
    return "—" if raw.blank?
    value = raw.is_a?(BigDecimal) ? raw : BigDecimal(raw.to_s)
    "#{number_with_precision(value, precision: 2, delimiter: " ", separator: ",")} #{currency}"
  rescue ArgumentError
    raw.to_s
  end

  def ksef_fmt_qty(raw)
    return "—" if raw.blank?
    raw.to_s
  end

  def ksef_fmt_date(raw)
    return "—" if raw.blank?
    Date.parse(raw.to_s).strftime("%Y-%m-%d")
  rescue ArgumentError
    raw.to_s
  end

  def ksef_fmt_datetime(raw)
    return "—" if raw.blank?
    Time.parse(raw.to_s).strftime("%Y-%m-%d %H:%M")
  rescue ArgumentError
    raw.to_s
  end

  def ksef_label(code, dictionary)
    dictionary[code.to_s] || code.to_s
  end

  def ksef_yesno(value)
    return "—" if value.blank?
    case value.to_s
    when "1" then "TAK"
    when "2" then "NIE"
    else value.to_s
    end
  end

  def ksef_present?(value)
    !value.nil? && !value.to_s.strip.empty?
  end
end
