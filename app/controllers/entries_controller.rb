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
    @referer = request.referer

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @entry }
    end
  end

  # POST /entries
  # POST /entries.json
  # creates Entry and related Items
  def create
    @referer = params[:entry][:referer]
    @entry = Entry.new(entry_params)
   
    if params[:is_linked]
      linked_entry = Entry.new(params[:linked_entry])
      linked_entry = copy_to_linked_entry(@entry, linked_entry)
      @entry.linked_entry = linked_entry
    end

    authorize! :create, @entry

    respond_to do |format|
      if @entry.save
        format.html do
          if params[:entry][:referer]
            redirect_to params[:entry][:referer], notice: 'Wpis utworzony'
          else
            redirect_to @entry.journal, notice: 'Wpis utworzony'
          end
        end
        format.json { render json: @entry, status: :created, location: @entry }
      else
        @journal = @entry.journal

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
    @referer = request.referer
  end

  # PUT /entries/1
  # PUT /entries/1.json
  def update
    @referer = params[:entry][:referer]
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
      if @entry.update_attributes(entry_params)
        format.html do
          if params[:entry][:referer]
            redirect_to params[:entry][:referer], notice: 'Zmiany zapisane'
          else
            redirect_to @journal, notice: 'Zmiany zapisane'
          end
        end
        format.json { head :ok }
      else
        create_empty_items(@entry, @journal.year)
        @sorted_items = @entry.items.sort_by {|item| item.category.position.to_s}

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
      unless entry.has_category(category)
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

  private

  def entry_params
    if params[:entry]
      params.require(:entry).permit(:date, :name, :document_number, :journal_id, :is_expense, :linked_entry,
                                    :items_attributes => [:id, :amount, :amount_one_percent, :category_id, :grant_id,
                                      :item_grants_attributes => [:id, :amount, :grant_id, :item_id]])
    end
  end
end
