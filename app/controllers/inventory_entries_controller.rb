class InventoryEntriesController < ApplicationController
  # GET /inventory_entries
  # GET /inventory_entries.json
  def index
    @user_units = Unit.find_by_user(current_user)

    if @user_units.empty?
      redirect_to inventory_entries_no_units_path
      return
    end

    if (! params[:unit_id].blank?)
      session[:current_unit_id] = params[:unit_id].to_i
    end

    if (session[:current_unit_id])
      @unit = Unit.find(session[:current_unit_id])
    else
      @unit = @user_units.first
      session[:current_unit_id] = @unit.id
    end

    if (! params[:year].blank?)
      session[:current_year] = params[:year].to_i
    end

    if (session[:current_year])
      current_year = session[:current_year].to_i
    else
      current_year = Time.now.year
      session[:current_year] = current_year
    end

    journal_type = JournalType.find(JournalType::FINANCE_TYPE_ID)
    @years = @unit.find_journal_years(journal_type).sort!

    authorize! :view_unit_entries, @unit

    show_all = false
    if current_year == 0 then
      show_all = true
      current_year = Time.now.year
      session[:current_year] = current_year
    end

    @inventory_entries_all = InventoryEntry.where(:unit_id => @unit.id).order('date', 'id')
    @inventory_entries_current_year = InventoryEntry.where(:unit_id => @unit.id).by_year(current_year).order('date', 'id')
    @inventory_entries = InventoryEntry.where(:unit_id => @unit.id).by_year(current_year).order('date', 'id').paginate(:page => params[:page], :per_page => 10)

    @sum_total_value = @inventory_entries_current_year.map(&:signed_total_value).sum

    page = params[:page].to_i
    @start_position = page < 1 ? 0 : (page.to_i - 1) * 10

    oldest_ziher_year = 2005

    inventoryVerifier = InventoryEntryVerifier.new(@unit)
    years_to_verify = (oldest_ziher_year..Time.now.year).to_a
    unless inventoryVerifier.verify(years_to_verify)
      flash.now[:alert] = inventoryVerifier.errors.values.join("<br/><br/>")
      puts inventoryVerifier.errors.values
    end

    respond_to do |format|
      format.html {
        @pdf_inventory_link = inventory_entries_path(:format => :pdf, :year => current_year)
        @pdf_all_inventory_link = inventory_entries_path(:format => :pdf, :year => "0")

        render 'index'
      }
      format.pdf {
        @generation_time = Time.now

        if (show_all)
          @inventory_entries = @inventory_entries_all
          @sum_total_value = @inventory_entries_all.map(&:signed_total_value).sum
          year_from = @inventory_entries_all.first.date.year
          year_to = @inventory_entries_all.last.date.year
          @years_label = "lata #{year_from}-#{year_to}"
        else
          @inventory_entries = @inventory_entries_current_year
          @years_label = "#{current_year} rok"
        end

        render pdf: "ksiazka_inwentarzowa_#{current_year.to_s}_#{get_time_postfix}",
               template: 'inventory_entries/index',
               show_as_html: false,
               orientation: 'Landscape',
               footer: { left: "Sporządził #{current_user.first_name} #{current_user.last_name}, #{Time.now.strftime ('%Y-%m-%d %H:%M:%S')}",
                         center: "ziher.zhr.pl/#{ENV['RAILS_RELATIVE_URL_ROOT']}",
                         right: 'Strona [page] z [topage]',
                         font_size: 9
               }
      }
    end
  end

  # GET /inventory_entries/1
  # GET /inventory_entries/1.json
  def show
    @inventory_entry = InventoryEntry.find(params[:id])
    authorize! :read, @inventory_entry

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @inventory_entry }
    end
  end

  # GET /inventory_entries/new
  # GET /inventory_entries/new.json
  def new
    @unit = Unit.find_by_id(session[:current_unit_id])
    @inventory_entry = InventoryEntry.new(:is_expense => params[:is_expense])

    @inventory_entry.unit = @unit

    authorize! :create, @inventory_entry

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @inventory_entry }
    end
  end

  # GET /inventory_entries/1/edit
  def edit
    @unit = Unit.find_by_id(session[:current_unit_id])
    @inventory_entry = InventoryEntry.find(params[:id])

    authorize! :update, @inventory_entry
  end

  # POST /inventory_entries
  # POST /inventory_entries.json
  def create
    @unit = Unit.find_by_id(session[:current_unit_id])
    @inventory_entry = InventoryEntry.new(inventory_entries_params)
    authorize! :create, @inventory_entry

    respond_to do |format|
      if @inventory_entry.save
        format.html { redirect_to @inventory_entry, notice: 'Wpis utworzony.' }
        format.json { render json: @inventory_entry, status: :created, location: @inventory_entry }
      else
        format.html { render action: "new" }
        format.json { render json: @inventory_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /inventory_entries/1
  # PUT /inventory_entries/1.json
  def update
    @unit = Unit.find_by_id(session[:current_unit_id])
    @inventory_entry = InventoryEntry.find(params[:id])

    authorize! :update, @inventory_entry

    respond_to do |format|
      if @inventory_entry.update_attributes(inventory_entries_params)
        format.html { redirect_to @inventory_entry, notice: 'Zmiany zapisane.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @inventory_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /inventory_entries/1
  # DELETE /inventory_entries/1.json
  def destroy
    @inventory_entry = InventoryEntry.find(params[:id])
    authorize! :delete, @inventory_entry

    @inventory_entry.destroy

    respond_to do |format|
      format.html { redirect_to inventory_entries_url }
      format.json { head :ok }
    end
  end

  # GET /inventory_entries/fixed_assets_report
  def fixed_assets_report
    unless current_user.is_superadmin
      redirect_to root_path, alert: I18n.t(:default, :scope => :unauthorized)
      return
    end

    @inventory_entries = InventoryEntry.all.to_a.sort_by!{|entry| entry.date}

    render 'fixed_assets_report', :formats => [:csv]

    response.headers['Content-Type'] = 'text/csv"'
    response.headers['Content-Disposition'] = 'attachment; filename="spis_z_natury.csv"'
  end

  def no_units_to_show
    flash.now[:info] = "Nie masz przypisanej żadnej jednostki, skontaktuj się z administratorem."

    respond_to do |format|
      format.html # no_units_to_show.html.erb
    end
  end

  private

  def inventory_entries_params
    if params[:inventory_entry]
      params.require(:inventory_entry).permit(:date, :stock_number, :name, :document_number, :amount, :is_expense,
                                              :total_value, :unit_id, :inventory_source_id, :remark)
    end
  end

  def get_time_postfix
    @generation_time.strftime('%Y%m%d%H%M%S')
  end

end
