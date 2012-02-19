class RevenueCashEntriesController < ApplicationController
  # GET /revenue_cash_entries
  # GET /revenue_cash_entries.json
  def index
    @revenue_cash_entries = RevenueCashEntry.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @revenue_cash_entries }
    end
  end

  # GET /revenue_cash_entries/1
  # GET /revenue_cash_entries/1.json
  def show
    @revenue_cash_entry = RevenueCashEntry.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @revenue_cash_entry }
    end
  end

  # GET /revenue_cash_entries/new
  # GET /revenue_cash_entries/new.json
  def new
    @revenue_cash_entry = RevenueCashEntry.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @revenue_cash_entry }
    end
  end

  # GET /revenue_cash_entries/1/edit
  def edit
    @revenue_cash_entry = RevenueCashEntry.find(params[:id])
  end

  # POST /revenue_cash_entries
  # POST /revenue_cash_entries.json
  def create
    @revenue_cash_entry = RevenueCashEntry.new(params[:revenue_cash_entry])

    respond_to do |format|
      if @revenue_cash_entry.save
        format.html { redirect_to @revenue_cash_entry, notice: 'Revenue cash entry was successfully created.' }
        format.json { render json: @revenue_cash_entry, status: :created, location: @revenue_cash_entry }
      else
        format.html { render action: "new" }
        format.json { render json: @revenue_cash_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /revenue_cash_entries/1
  # PUT /revenue_cash_entries/1.json
  def update
    @revenue_cash_entry = RevenueCashEntry.find(params[:id])

    respond_to do |format|
      if @revenue_cash_entry.update_attributes(params[:revenue_cash_entry])
        format.html { redirect_to @revenue_cash_entry, notice: 'Revenue cash entry was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @revenue_cash_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /revenue_cash_entries/1
  # DELETE /revenue_cash_entries/1.json
  def destroy
    @revenue_cash_entry = RevenueCashEntry.find(params[:id])
    @revenue_cash_entry.destroy

    respond_to do |format|
      format.html { redirect_to revenue_cash_entries_url }
      format.json { head :ok }
    end
  end
end
