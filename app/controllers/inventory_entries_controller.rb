class InventoryEntriesController < ApplicationController
  # GET /inventory_entries
  # GET /inventory_entries.json
  def index
    @inventory_entries = InventoryEntry.all
    @user_units = Unit.find_by_user(current_user)

    if (params[:unit_id])
      session[:current_unit_id] = params[:unit_id].to_i
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @inventory_entries }
    end
  end

  # GET /inventory_entries/1
  # GET /inventory_entries/1.json
  def show
    @inventory_entry = InventoryEntry.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @inventory_entry }
    end
  end

  # GET /inventory_entries/new
  # GET /inventory_entries/new.json
  def new
    @inventory_entry = InventoryEntry.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @inventory_entry }
    end
  end

  # GET /inventory_entries/1/edit
  def edit
    @inventory_entry = InventoryEntry.find(params[:id])
  end

  # POST /inventory_entries
  # POST /inventory_entries.json
  def create
    @inventory_entry = InventoryEntry.new(params[:inventory_entry])

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
    @inventory_entry = InventoryEntry.find(params[:id])

    respond_to do |format|
      if @inventory_entry.update_attributes(params[:inventory_entry])
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
    @inventory_entry.destroy

    respond_to do |format|
      format.html { redirect_to inventory_entries_url }
      format.json { head :ok }
    end
  end
end
