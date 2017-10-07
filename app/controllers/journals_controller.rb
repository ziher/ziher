#!/bin/env ruby
# encoding: utf-8
class JournalsController < ApplicationController
  load_and_authorize_resource

  helper JournalsHelper

  # GET /journals
  # GET /journals.json
  def index
    if (params[:unit_id] && params[:journal_type_id] && params[:year])
      journal = Journal.find_by_unit_and_year_and_type(Unit.find(params[:unit_id]), params[:year], JournalType.find(params[:journal_type_id]))
      if journal.nil?
        # if there is no such Journal - just create one

        if current_user.is_superadmin && params[:year].to_i == Time.now.year - 1
          # only superadmin can create journal for the previous year
          journal = Journal.get_previous_for_type(params[:unit_id], params[:journal_type_id])
        else
          journal = Journal.get_current_for_type(params[:unit_id], params[:journal_type_id])
        end
      end
      session[:current_unit_id] = journal.unit.id
      session[:current_year] = journal.year
      redirect_to journal
      return
    else
      redirect_to default_finance_journal_path
      return
    end
  end

  # GET /journals/1
  # GET /journals/1.json
  def show
    #override CanCan's auto-fetched journal
    @journal = Journal.includes(:entries => :items).find_by_id(@journal.id)

    @categories_expense = Category.find_by_year_and_type(@journal.year, true)
    @categories_income = Category.find_by_year_and_type(@journal.year, false)
    @entries = @journal.entries.order('date').paginate(:page => params[:page], :per_page => 10)
    @user_units = Unit.find_by_user(current_user)
    @years = @journal.unit.find_journal_years(@journal.journal_type)

    if current_user.is_superadmin
      @years << Time.now.year - 1
      @years.uniq!
    end

    @years.sort!

    session[:current_year] = @journal.year
    session[:current_unit_id] = @journal.unit.id

    unless @journal.verify_journal
      flash.now[:alert] = @journal.errors.values.join("<br/>")
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @journal }
    end
  end

  def default
    # get default journal
    journal_type = JournalType.find(params[:journal_type_id])

    @journal = Journal.get_default(journal_type, current_user, session[:current_unit_id], session[:current_year])
    unless @journal.nil?
      flash.keep
      redirect_to journal_path(@journal)
    else
      respond_to do |format|
        format.html # default.html.erb
      end
    end
  end

  # GET /journals/new
  # GET /journals/new.json
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @journal }
    end
  end

  # GET /journals/1/edit
  def edit
  end

  # GET /journals/1/open
  def open
    @journal = Journal.find(params[:id])
    @journal.is_open = true

    respond_to do |format|
      if @journal.save
        format.html { redirect_to journal_path(@journal), notice: 'Książka otwarta.' }
        format.json { render json: @journal, status: :opened, location: @journal }
      else
        format.html { redirect_to journals_url, alert: "Błąd otwierania książki: " + @journal.errors.full_messages.join(', ') }
        format.json { render json: @journal.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /journals/1/close
  def close
    @journal = Journal.find(params[:id])

    respond_to do |format|
      if @journal.close
        format.html { redirect_to journal_path(@journal), notice: 'Książka zamknięta.' }
        format.json { render json: @journal, status: :closed, location: @journal }
      else
        format.html { redirect_to journals_url, alert: "Błąd zamykania książki: " + @journal.errors.values.join(', ') }
        format.json { render json: @journal.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /journals
  # POST /journals.json
  def create
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
end
