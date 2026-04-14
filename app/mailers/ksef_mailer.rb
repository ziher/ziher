class KsefMailer < ApplicationMailer
  def invoice_assigned(invoice)
    @invoice = invoice
    recipients = unit_manager_emails(invoice.unit)

    if recipients.empty?
      Rails.logger.tagged("KSeF") { |l| l.warn("invoice_assigned: no recipients for unit_id=#{invoice.unit_id}, skipping") }
      return NullMail.new
    end

    mail(
      to: recipients,
      subject: "[ZiHeR] Nowa faktura KSeF do wyjaśnienia: #{invoice.invoice_number.presence || invoice.ksef_number}"
    )
  end

  private

  def unit_manager_emails(unit)
    return [] if unit.nil?
    unit.user_unit_associations
        .where(can_manage_entries: true)
        .includes(:user)
        .map { |uua| uua.user&.email }
        .compact_blank
  end

  class NullMail
    def deliver_now; end
    def deliver_later; end
    def message; nil; end
  end
end
