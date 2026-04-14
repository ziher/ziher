module Ksef
  class Importer
    class InvalidImport < StandardError; end

    def self.call(invoice:, journal:, category:, user:)
      new(invoice: invoice, journal: journal, category: category, user: user).call
    end

    def initialize(invoice:, journal:, category:, user:)
      @invoice = invoice
      @journal = journal
      @category = category
      @user = user
    end

    def call
      raise InvalidImport, "invoice already imported" if @invoice.imported?
      raise InvalidImport, "invoice has no unit" if @invoice.unit_id.nil?
      raise InvalidImport, "journal unit mismatch" if @journal.unit_id != @invoice.unit_id

      ApplicationRecord.transaction do
        entry = Entry.new(
          journal: @journal,
          date: @invoice.issue_date,
          name: @invoice.seller_name.presence || "KSeF #{@invoice.ksef_number}",
          document_number: @invoice.invoice_number.presence || @invoice.ksef_number,
          is_expense: true
        )
        entry.items.build(
          category: @category,
          amount: @invoice.gross_amount
        )
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
