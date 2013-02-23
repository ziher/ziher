class EntriesController < ApplicationController
  # GET /entries/1
  # GET /entries/1.json
  def show
    @entry = Entry.find(params[:id])
    @categories = Category.where(:year => @entry.journal.year, :is_expense => @entry.is_expense)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @entry }
    end
  end

  # GET /entries/new
  # GET /entries/new.json
  def new
    @journal = Journal.find(params[:journal_id])
    @entry = Entry.new(:is_expense => params[:is_expense])
    @entry.items = Array.new
    Category.where(:year => @journal.year, :is_expense => @entry.is_expense).each do |category|
      @item = Item.new(:category_id => category.id)
      @entry.items << @item
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @entry }
    end
  end

  # GET /entries/1/edit
  def edit
    @entry = Entry.find(params[:id])
    @journal = @entry.journal
    @categories = Category.where(:year => @entry.journal.year)
    Category.where(:year => @entry.journal.year, :is_expense => @entry.is_expense).each do |category|
      if not @entry.has_category(category.id)
        @item = Item.new(:category_id => category.id)
        @entry.items << @item
      end
    end
  end

  # POST /entries
  # POST /entries.json
  # creates Entry and related Items
  def create
    @entry = Entry.new(params[:entry])

    respond_to do |format|
      if @entry.save!
        format.html { redirect_to @entry, notice: 'Wpis utworzony' }
        format.json { render json: @entry, status: :created, location: @entry }
      else
        format.html { render action: "new" }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /entries/1
  # PUT /entries/1.json
  def update
    @entry = Entry.find(params[:id])
    @journal = @entry.journal

    respond_to do |format|
      if @entry.update_attributes(params[:entry])
        format.html { redirect_to @entry, notice: 'Zmiany zapisane.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /entries/1
  # DELETE /entries/1.json
  def destroy
    @entry = Entry.find(params[:id])
    journal = @entry.journal
    @entry.destroy

    respond_to do |format|
      format.html { redirect_to journal_url(journal) }
      format.json { head :ok }
    end
  end
end
