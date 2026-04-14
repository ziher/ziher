class KsefMailer < ApplicationMailer
  def invoice_assigned(invoice)
    @invoice = invoice
    mail(to: "placeholder@example.com", subject: "KSeF: przypisano fakturę") do |format|
      format.text { render plain: "Invoice assigned (stub – filled in Task 19)." }
    end
  end
end
