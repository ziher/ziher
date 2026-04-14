class Ksef::InvoicesController < Ksef::BaseController
  include Pagy::Backend

  LIST_COLUMNS = %i[
    id ksef_number invoice_number issue_date seller_name gross_amount currency
    status unit_id assigned_by_id assigned_at note imported_entry_id
  ].freeze

  PER_PAGE = 50

  STATUS_TABS = %w[pending unassigned assigned imported].freeze

  before_action :load_invoice, only: [:show, :assign, :release, :dismiss, :import, :do_import]

  def index
    @show_setup_warning = !@ksef_setting.configured?
    base = KsefInvoice.for_user(current_user)

    @counts = base.group(:status).count
    @active_status = resolve_active_status
    @status_tabs = STATUS_TABS

    scope = base.select(LIST_COLUMNS)
                .includes(:unit, :imported_entry, :assigned_by)
                .where(status: @active_status)
                .order(issue_date: :desc, id: :desc)

    @pagy, @invoices = pagy(scope, items: PER_PAGE)
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
    @lines = Ksef::ImportLines.from_invoice(@invoice)
    @journals = candidate_journals_for_import
    @categories = Category.where(year: @invoice.issue_date.year, is_expense: true).order(:name)
    @default_journal_id = @journals.first&.id
  end

  def do_import
    authorize! :import, @invoice
    journal = Journal.find(params[:import][:journal_id])
    lines = submitted_import_lines
    entry = Ksef::Importer.call(
      invoice: @invoice,
      journal: journal,
      user: current_user,
      lines: lines,
      description: params.dig(:import, :description)
    )
    redirect_to journal_path(journal), notice: "Wpis #{entry.id} utworzony z faktury KSeF."
  rescue Ksef::Importer::InvalidImport => e
    redirect_to import_ksef_invoice_path(@invoice), alert: e.message
  end

  private

  def load_invoice
    @invoice = KsefInvoice.find(params[:id])
  end

  def resolve_active_status
    requested = params[:status].to_s
    return requested if STATUS_TABS.include?(requested)

    default_status_for(current_user)
  end

  def candidate_journals_for_import
    @invoice.unit.journals
            .includes(:journal_type)
            .where(is_open: true, year: @invoice.issue_date.year)
            .order(:journal_type_id, year: :desc)
  end

  def submitted_import_lines
    lines_params = params.dig(:import, :lines)
    return [] if lines_params.blank?

    lines_params.values.map do |line|
      { category_id: line[:category_id], amount: line[:amount] }
    end
  end

  def default_status_for(user)
    if user.is_superadmin
      @counts["pending"].to_i.positive? ? "pending" : "unassigned"
    else
      "unassigned"
    end
  end
end
