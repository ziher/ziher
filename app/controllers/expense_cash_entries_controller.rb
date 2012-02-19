class ExpenseCashEntriesController < ApplicationController
  # GET /expense_cash_entries
  # GET /expense_cash_entries.json
  def index
    @expense_cash_entries = ExpenseCashEntry.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @expense_cash_entries }
    end
  end

  # GET /expense_cash_entries/1
  # GET /expense_cash_entries/1.json
  def show
    @expense_cash_entry = ExpenseCashEntry.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @expense_cash_entry }
    end
  end

  # GET /expense_cash_entries/new
  # GET /expense_cash_entries/new.json
  def new
    @expense_cash_entry = ExpenseCashEntry.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @expense_cash_entry }
    end
  end

  # GET /expense_cash_entries/1/edit
  def edit
    @expense_cash_entry = ExpenseCashEntry.find(params[:id])
  end

  # POST /expense_cash_entries
  # POST /expense_cash_entries.json
  def create
    @expense_cash_entry = ExpenseCashEntry.new(params[:expense_cash_entry])

    respond_to do |format|
      if @expense_cash_entry.save
        format.html { redirect_to @expense_cash_entry, notice: 'Expense cash entry was successfully created.' }
        format.json { render json: @expense_cash_entry, status: :created, location: @expense_cash_entry }
      else
        format.html { render action: "new" }
        format.json { render json: @expense_cash_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /expense_cash_entries/1
  # PUT /expense_cash_entries/1.json
  def update
    @expense_cash_entry = ExpenseCashEntry.find(params[:id])

    respond_to do |format|
      if @expense_cash_entry.update_attributes(params[:expense_cash_entry])
        format.html { redirect_to @expense_cash_entry, notice: 'Expense cash entry was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @expense_cash_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /expense_cash_entries/1
  # DELETE /expense_cash_entries/1.json
  def destroy
    @expense_cash_entry = ExpenseCashEntry.find(params[:id])
    @expense_cash_entry.destroy

    respond_to do |format|
      format.html { redirect_to expense_cash_entries_url }
      format.json { head :ok }
    end
  end
end
