class EntriesController < ApplicationController
  # GET /entries/1
  # GET /entries/1.json
  def show
    @entry = Entry.find(params[:id])
    authorize! :read, @entry
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
    @other_journals = @journal.journals_for_linked_entry
    @entry = Entry.new(:is_expense => params[:is_expense], :journal_id => params[:journal_id])
    authorize! :create, @entry
    @entry.items = []
    create_empty_items(@entry, @journal.year)
    
    @linked_entry = create_empty_items_in_linked_entry(@entry)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @entry }
    end
  end

  # POST /entries
  # POST /entries.json
  # creates Entry and related Items
  def create
    @entry = Entry.new(params[:entry])
   
    if params[:is_linked]
      linked_entry = Entry.new(params[:linked_entry])
      linked_entry = copy_to_linked_entry(@entry, linked_entry)
      @entry.linked_entry = linked_entry
    end

    authorize! :create, @entry

    respond_to do |format|
      if @entry.save!
        format.html { redirect_to @entry.journal, notice: 'Wpis utworzony' }
        format.json { render json: @entry, status: :created, location: @entry }
      else
        format.html { render action: "new" }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /entries/1/edit
  def edit
    @entry = Entry.find(params[:id])
    authorize! :update, @entry
    @journal = @entry.journal
    @other_journals = @journal.journals_for_linked_entry
    @categories = Category.where(:year => @entry.journal.year, :is_expense => @entry.is_expense)
    create_empty_items(@entry, @journal.year)

    @linked_entry = create_empty_items_in_linked_entry(@entry)

    @sorted_items = @entry.items.sort_by {|item| item.category.position.to_s}
  end

  # PUT /entries/1
  # PUT /entries/1.json
  def update
    @entry = Entry.find(params[:id])
    authorize! :update, @entry
    @journal = @entry.journal
    @other_journals = @journal.journals_for_linked_entry

    if params[:is_linked]
      if @entry.linked_entry
        @entry.linked_entry.update_attributes(params[:linked_entry])
        linked_entry = @entry.linked_entry
      else
        linked_entry = Entry.new(params[:linked_entry])
      end
      @entry.linked_entry = copy_to_linked_entry(@entry, linked_entry)
      @linked_entry = @entry.linked_entry
    end

    respond_to do |format|
      if @entry.update_attributes(params[:entry])
        format.html { redirect_to @journal, notice: 'Zmiany zapisane.' }
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
    authorize! :destroy, @entry
    journal = @entry.journal
    @entry.destroy

    respond_to do |format|
      format.html { redirect_to journal_url(journal) }
      format.json { head :ok }
    end
  end

  def create_empty_items_in_linked_entry(entry)
    if entry.linked_entry
      linked_entry = entry.linked_entry
    else
      linked_entry = Entry.new(:is_expense => !entry.is_expense)
      linked_entry.items = []
      linked_entry.is_expense = !entry.is_expense
    end
    create_empty_items(linked_entry, entry.journal.year)

    return linked_entry
  end

  def create_empty_items(entry, year)
    Category.where(:year => year, :is_expense => entry.is_expense).each do |category|
      if not entry.has_category(category)
        entry.items << Item.new(:category_id => category.id)
      end
    end
  end

  def copy_to_linked_entry(entry, linked_entry)
      linked_entry.date = entry.date
      linked_entry.name = entry.name
      linked_entry.is_expense = !entry.is_expense
      linked_entry.document_number = entry.document_number
      return linked_entry
  end
end
