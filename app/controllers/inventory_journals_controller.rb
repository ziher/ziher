#!/bin/env ruby
# encoding: utf-8
class InventoryJournalsController < ApplicationController
  # GET /inventory_journals
  # GET /inventory_journals.json
  def index
    @inventory_journals = InventoryJournal.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @inventory_journals }
    end
  end

  # GET /inventory_journals/1
  # GET /inventory_journals/1.json
  def show
    @inventory_journal = InventoryJournal.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @inventory_journal }
    end
  end

  # GET /inventory_journals/new
  # GET /inventory_journals/new.json
  def new
    @inventory_journal = InventoryJournal.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @inventory_journal }
    end
  end

  # GET /inventory_journals/1/edit
  def edit
    @inventory_journal = InventoryJournal.find(params[:id])
  end

  # POST /inventory_journals
  # POST /inventory_journals.json
  def create
    @inventory_journal = InventoryJournal.new(params[:inventory_journal])

    respond_to do |format|
      if @inventory_journal.save
        format.html { redirect_to @inventory_journal, notice: 'Książka utworzona.' }
        format.json { render json: @inventory_journal, status: :created, location: @inventory_journal }
      else
        format.html { render action: "new" }
        format.json { render json: @inventory_journal.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /inventory_journals/1
  # PUT /inventory_journals/1.json
  def update
    @inventory_journal = InventoryJournal.find(params[:id])

    respond_to do |format|
      if @inventory_journal.update_attributes(params[:inventory_journal])
        format.html { redirect_to @inventory_journal, notice: 'Zmiany zapisane.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @inventory_journal.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /inventory_journals/1
  # DELETE /inventory_journals/1.json
  def destroy
    @inventory_journal = InventoryJournal.find(params[:id])
    @inventory_journal.destroy

    respond_to do |format|
      format.html { redirect_to inventory_journals_url }
      format.json { head :ok }
    end
  end
end
