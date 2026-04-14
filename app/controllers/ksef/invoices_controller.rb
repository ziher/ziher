class Ksef::InvoicesController < Ksef::BaseController
  before_action :load_invoice, only: [:show, :assign, :dismiss, :import, :do_import]

  def index
    @show_setup_warning = !@ksef_setting.configured?
    scope = KsefInvoice.for_user(current_user)
                       .includes(:unit, :imported_entry)
                       .order(issue_date: :desc, id: :desc)
    @claimable = scope.where(unit_id: nil)
    @assigned  = scope.where.not(unit_id: nil)
  end

  def show
    authorize! :read, @invoice
    @document = Ksef::Parser.parse(@invoice.invoice_xml) if @invoice.invoice_xml.present?
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "ksef-#{@invoice.ksef_number}",
               template: "ksef/invoices/show",
               formats: [:pdf],
               layout: false,
               page_size: "A4",
               margin: { top: 15, bottom: 15, left: 15, right: 15 },
               footer: {
                 font_size: 8,
                 right: "[page] z [topage]",
                 spacing: 4
               },
               encoding: "UTF-8"
      end
    end
  end

  def assign
    authorize! :manage, @invoice
    permitted = params.require(:ksef_invoice).permit(:unit_id, :note)
    @invoice.assign_attributes(
      unit_id: permitted[:unit_id],
      note:    permitted[:note],
      status:  :to_clarify,
      assigned_by: current_user,
      assigned_at: Time.current
    )
    if @invoice.save
      KsefMailer.invoice_assigned(@invoice).deliver_later
      redirect_to ksef_invoices_path, notice: "Faktura przypisana do jednostki."
    else
      redirect_to ksef_invoice_path(@invoice), alert: @invoice.errors.full_messages.join(", ")
    end
  end

  def dismiss
    authorize! :manage, @invoice
    @invoice.update!(status: :dismissed)
    redirect_to ksef_invoices_path, notice: "Faktura odrzucona."
  end

  def import
    authorize! :import, @invoice
    @journals = @invoice.unit.journals.where(is_open: true).order(year: :desc)
    @categories = Category.where(year: @invoice.issue_date.year).order(:name)
  end

  def do_import
    authorize! :import, @invoice
    journal = Journal.find(params[:import][:journal_id])
    category = Category.find(params[:import][:category_id])
    entry = Ksef::Importer.call(invoice: @invoice, journal: journal, category: category, user: current_user)
    redirect_to journal_path(journal), notice: "Wpis #{entry.id} utworzony z faktury KSeF."
  rescue Ksef::Importer::InvalidImport => e
    redirect_to ksef_invoice_path(@invoice), alert: e.message
  end

  private

  def load_invoice
    @invoice = KsefInvoice.find(params[:id])
  end
end
