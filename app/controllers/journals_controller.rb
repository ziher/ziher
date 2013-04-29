#!/bin/env ruby
# encoding: utf-8
class JournalsController < ApplicationController
  # GET /journals
  # GET /journals.json
  def index
    if (params[:unit_id] && params[:journal_type_id] && params[:year])
      journal = Journal.find_previous_for_type(Unit.find(params[:unit_id]), JournalType.find(params[:journal_type_id]), params[:year])
      if (journal != nil)
        redirect_to journal
        return
      else
        journal = Journal.find_current_for_type(Unit.find(params[:unit_id]), JournalType.find(params[:journal_type_id]))
        if (journal != nil)
          redirect_to journal
          return
        else
          @journals = Journal.where(:journal_type_id => params[:journal_type_id])
        end
      end
    elsif (params[:journal_type_id])
      @journals = Journal.where(:journal_type_id => params[:journal_type_id])
    else
      @journals = Journal.all
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @journals }
    end
  end

  # GET /journals/1
  # GET /journals/1.json
  def show
    @journal = Journal.find(params[:id])
    @categories_expense = Category.find_by_year_and_type(@journal.year, true)
    @categories_income = Category.find_by_year_and_type(@journal.year, false)
    @entries = @journal.entries
    @user_units = Unit.find_by_user(current_user)
    @years = @journal.find_all_years()

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @journal }
    end
  end

  def default
    # get default journal
    journal_type = JournalType.find(params[:journal_type_id])
    @journal = Journal.get_default(journal_type, current_user)
    if (@journal != nil)
      redirect_to journal_path(@journal)
    else
      redirect_to journals_path
    end
  end

  # GET /journals/new
  # GET /journals/new.json
  def new
    @journal = Journal.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @journal }
    end
  end

  # GET /journals/1/edit
  def edit
    @journal = Journal.find(params[:id])
  end

  # GET /journals/1/open
  def open
    @journal = Journal.find(params[:id])
    @journal.is_open = true

    respond_to do |format|
      if @journal.save
        format.html { redirect_to journals_url, notice: 'Książka otwarta.' }
        format.json { render json: @journal, status: :opened, location: @journal }
      else
        format.html { redirect_to journals_url, notice: "Błąd otwierania książki: " + @journal.errors.full_messages.join(', ') }
        format.json { render json: @journal.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /journals/1/close
  def close
    @journal = Journal.find(params[:id])
    @journal.is_open = false

    respond_to do |format|
      if @journal.save
        format.html { redirect_to journals_url, notice: 'Książka zamknięta.' }
        format.json { render json: @journal, status: :closed, location: @journal }
      else
        format.html { redirect_to journals_url, notice: "Błąd zamykania książki: " + @journal.errors.full_messages.join(', ') }
        format.json { render json: @journal.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /journals
  # POST /journals.json
  def create
    @journal = Journal.new(params[:journal])

    respond_to do |format|
      if @journal.save
        format.html { redirect_to @journal, notice: 'Książka  utworzona.' }
        format.json { render json: @journal, status: :created, location: @journal }
      else
        format.html { render action: "new" }
        format.json { render json: @journal.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /journals/1
  # PUT /journals/1.json
  def update
    @journal = Journal.find(params[:id])

    respond_to do |format|
      if @journal.update_attributes(params[:journal])
        format.html { redirect_to @journal, notice: 'Zmiany zapisane.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @journal.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /journals/1
  # DELETE /journals/1.json
  def destroy
    @journal = Journal.find(params[:id])
    @journal.destroy

    respond_to do |format|
      format.html { redirect_to journals_url }
      format.json { head :ok }
    end
  end
end
