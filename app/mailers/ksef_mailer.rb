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

  def sync_failed(error)
    @error_class   = error.class.to_s
    @error_message = error.message.truncate(500)
    recipients     = superadmin_emails

    if recipients.empty?
      Rails.logger.tagged("KSeF") { |l| l.warn("sync_failed: no superadmin recipients, skipping email") }
      return NullMail.new
    end

    mail(
      to:      recipients,
      subject: "[ZiHeR] KSeF synchronizacja nieudana: #{@error_class}"
    )
  end

  def cert_expiring_soon(days_left)
    @days_left = days_left
    recipients  = superadmin_emails

    if recipients.empty?
      Rails.logger.tagged("KSeF") { |l| l.warn("cert_expiring_soon: no superadmin recipients, skipping email") }
      return NullMail.new
    end

    mail(
      to:      recipients,
      subject: "[ZiHeR] KSeF certyfikat wygasa za #{days_left} #{days_left == 1 ? 'dzień' : 'dni'}"
    )
  end

  private

  def superadmin_emails
    User.where(is_superadmin: true).pluck(:email).compact_blank
  end

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
