module Ksef
  class CheckCertExpiryJob < ApplicationJob
    queue_as :default

    WARN_THRESHOLD_DAYS = 30

    def perform
      setting = KsefSetting.instance
      return if setting.cert_pem.blank?

      cert = OpenSSL::X509::Certificate.new(setting.cert_pem)
      days_left = ((cert.not_after - Time.current) / 1.day).floor

      if days_left <= WARN_THRESHOLD_DAYS
        Rails.logger.warn("KSeF certificate expires in #{days_left} days (#{cert.not_after})")
        KsefMailer.cert_expiring_soon(days_left).deliver_later
      end
    rescue OpenSSL::X509::CertificateError => e
      Rails.logger.error("KSeF cert parse error in CheckCertExpiryJob: #{e.message}")
    end
  end
end
