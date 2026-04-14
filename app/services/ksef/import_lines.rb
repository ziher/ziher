module Ksef
  module ImportLines
    Line = Struct.new(:nr, :nazwa, :amount_gross, keyword_init: true)

    def self.from_invoice(invoice)
      lines = parse_from_xml(invoice)
      return lines unless lines.empty?

      [fallback_line(invoice)]
    end

    def self.parse_from_xml(invoice)
      return [] if invoice.invoice_xml.blank?

      document = Ksef::Parser.parse(invoice.invoice_xml)
      rows = document.fa&.wiersze || []
      rows.filter_map { |row| to_line(row) }
    rescue StandardError => e
      Rails.logger.warn("Ksef::ImportLines parse failure for invoice #{invoice.id}: #{e.class}: #{e.message}")
      []
    end

    def self.fallback_line(invoice)
      Line.new(
        nr: "1",
        nazwa: invoice.seller_name.presence || invoice.ksef_number,
        amount_gross: invoice.gross_amount || BigDecimal("0")
      )
    end

    def self.to_line(row)
      amount = line_gross(row)
      return nil if amount.nil?

      Line.new(
        nr: row[:nr].to_s,
        nazwa: row[:nazwa].presence || "—",
        amount_gross: amount
      )
    end

    def self.line_gross(row)
      if row[:wartosc_brutto].present?
        BigDecimal(row[:wartosc_brutto])
      elsif row[:wartosc_netto].present?
        netto = BigDecimal(row[:wartosc_netto])
        (netto * (1 + vat_rate_factor(row[:stawka]))).round(2)
      elsif row[:cena_brutto].present? && row[:ilosc].present?
        (BigDecimal(row[:cena_brutto]) * BigDecimal(row[:ilosc])).round(2)
      end
    rescue ArgumentError
      nil
    end

    def self.vat_rate_factor(rate)
      return BigDecimal("0") if rate.blank? || %w[zw np oo].include?(rate.to_s.downcase)
      BigDecimal(rate.to_s) / 100
    rescue ArgumentError
      BigDecimal("0")
    end
  end
end
