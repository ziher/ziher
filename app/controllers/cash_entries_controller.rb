class CashEntriesController < ApplicationController
  # GET /cash_entries
  # GET /cash_entries.json
  def index
    @cash_entries = CashEntry.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @cash_entries }
    end
  end

  # GET /cash_entries/1
  # GET /cash_entries/1.json
  def show
    @cash_entry = CashEntry.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @cash_entry }
    end
  end

  # GET /cash_entries/new
  # GET /cash_entries/new.json
  def new
    @cash_entry = CashEntry.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @cash_entry }
    end
  end

  # GET /cash_entries/1/edit
  def edit
    @cash_entry = CashEntry.find(params[:id])
  end

  # POST /cash_entries
  # POST /cash_entries.json
  def create
    @cash_entry = CashEntry.new(params[:cash_entry])

    respond_to do |format|
      if @cash_entry.save
        format.html { redirect_to @cash_entry, notice: 'Cash entry was successfully created.' }
        format.json { render json: @cash_entry, status: :created, location: @cash_entry }
      else
        format.html { render action: "new" }
        format.json { render json: @cash_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /cash_entries/1
  # PUT /cash_entries/1.json
  def update
    @cash_entry = CashEntry.find(params[:id])

    respond_to do |format|
      if @cash_entry.update_attributes(params[:cash_entry])
        format.html { redirect_to @cash_entry, notice: 'Cash entry was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @cash_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cash_entries/1
  # DELETE /cash_entries/1.json
  def destroy
    @cash_entry = CashEntry.find(params[:id])
    @cash_entry.destroy

    respond_to do |format|
      format.html { redirect_to cash_entries_url }
      format.json { head :ok }
    end
  end
end
