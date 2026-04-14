class Ksef::InvoicesController < Ksef::BaseController
  before_action :load_invoice, only: [:show, :assign, :release, :dismiss, :import, :do_import]

  def index
    @show_setup_warning = !@ksef_setting.configured?
    scope = KsefInvoice.for_user(current_user)
                       .includes(:unit, :imported_entry, :assigned_by)
                       .order(issue_date: :desc, id: :desc)
    @pending          = scope.where(status: :pending)
    @claimable        = scope.where(status: :unassigned)
    @assigned_open    = scope.where(status: :assigned)
    @imported_history = scope.where(status: :imported)
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
    authorize! :assign, @invoice
    permitted = params.require(:ksef_invoice).permit(:unit_id, :note)
    unit = Unit.find(permitted[:unit_id])
    unless current_user.is_superadmin || current_user.can_manage_unit_entries(unit)
      redirect_to ksef_invoice_path(@invoice), alert: "Brak uprawnień do wybranej jednostki." and return
    end
    @invoice.assign_attributes(
      unit_id: unit.id,
      note:    permitted[:note],
      status:  :assigned,
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

  def release
    authorize! :release, @invoice
    unless @invoice.releasable?
      redirect_to ksef_invoice_path(@invoice), alert: "Nie można zwolnić faktury w tym statusie." and return
    end
    @invoice.update!(
      status: :unassigned,
      unit_id: nil,
      assigned_by: nil,
      assigned_at: nil
    )
    redirect_to ksef_invoices_path, notice: "Faktura oznaczona jako nieprzypisana."
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
