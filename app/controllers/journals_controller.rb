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

    if @journal.nil? or @journal.unit.is_active == false
      flash.keep
      redirect_to default_finance_journal_path
    end

    @categories_expense = Category.find_by_year_and_type(@journal.year, true)
    @categories_income = Category.find_by_year_and_type(@journal.year, false)
    all_entries = @journal.entries.order('date', 'id')
    @entries = all_entries.paginate(:page => params[:page], :per_page => 10)
    page = params[:page].to_i
    @start_position = page < 1 ? 0 : (page.to_i - 1) * 10
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
      format.html { # show.html.erb
        @pdf_report_link = journal_path(:format => :pdf)
      }
      format.json { render json: @journal }
      format.pdf {
        @entries = all_entries
        @generation_time = Time.now
        render pdf: "#{journal_type_prefix(@journal.journal_type)}_#{get_time_postfix}",
               template: 'journals/show',
               orientation: 'Landscape',
               show_as_html: false,
               footer: {left: "#{current_user.email}, #{Time.now.strftime ('%Y-%m-%d %H:%M:%S')}",
                        center: "ziher.zhr.pl#{ENV['RAILS_RELATIVE_URL_ROOT']}",
                        right: 'Strona [page] z [topage]',
                        font_size: 8
               }
      }
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

  # GET /journals/close_old
  def close_old
    respond_to do |format|
      Journal.close_old_open(session[:current_year].to_i)

      format.html { redirect_to all_finance_report_path}
    end
  end

  # GET /journals/close_current
  def close_current
    respond_to do |format|
      Journal.close_all_by_year(session[:current_year].to_i)

      format.html { redirect_to all_finance_report_path}
    end
  end

  private

  def get_time_postfix
    @generation_time.strftime('%Y%m%d%H%M%S')
  end

  def journal_type_prefix(journal_type)
    'ksiazka_' + journal_type.to_s.split(' ')[1]
  end
end
