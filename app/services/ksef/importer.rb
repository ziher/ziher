module Ksef
  class Importer
    class InvalidImport < StandardError; end

    def self.call(invoice:, journal:, user:, lines:, description: nil)
      new(invoice: invoice, journal: journal, user: user, lines: lines, description: description).call
    end

    def initialize(invoice:, journal:, user:, lines:, description: nil)
      @invoice = invoice
      @journal = journal
      @user = user
      @lines = Array(lines)
      @description = description.to_s.strip
    end

    def call
      raise InvalidImport, "faktura została już zaimportowana" if @invoice.imported?
      raise InvalidImport, "faktura nie jest przypisana do jednostki" if @invoice.unit_id.nil?
      raise InvalidImport, "jednostka książki nie pasuje do jednostki faktury" if @journal.unit_id != @invoice.unit_id
      raise InvalidImport, "brak pozycji do zaimportowania" if @lines.empty?
      raise InvalidImport, "każda pozycja musi mieć wybraną kategorię" if @lines.any? { |l| l[:category_id].to_i.zero? }

      totals = @lines.group_by { |l| l[:category_id].to_i }
                     .transform_values { |group| group.sum { |l| BigDecimal(l[:amount].to_s) } }
                     .reject { |_, amount| amount.zero? }

      raise InvalidImport, "suma kwot dla wszystkich pozycji wynosi 0" if totals.empty?

      if @invoice.gross_amount.present?
        submitted_total = totals.values.sum
        diff = (@invoice.gross_amount - submitted_total).abs
        if diff > BigDecimal("0.01")
          raise InvalidImport,
                "suma pozycji (#{submitted_total.to_f}) nie zgadza się z kwotą brutto faktury (#{@invoice.gross_amount.to_f})"
        end
      end

      ApplicationRecord.transaction do
        entry = Entry.new(
          journal: @journal,
          date: @invoice.issue_date,
          name: @description.presence || @invoice.seller_name.presence || "KSeF #{@invoice.ksef_number}",
          document_number: @invoice.invoice_number.presence || @invoice.ksef_number,
          is_expense: true
        )
        totals.each do |category_id, amount|
          entry.items.build(category_id: category_id, amount: amount)
        end
        entry.save!

        @invoice.update!(
          imported_entry: entry,
          status: :imported,
          unit_id: @journal.unit_id
        )

        entry
      end
    end
  end
end
