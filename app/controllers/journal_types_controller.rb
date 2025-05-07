#!/bin/env ruby
# encoding: utf-8
class JournalTypesController < ApplicationController
  # GET /journal_types
  # GET /journal_types.json
  def index
    @journal_types = JournalType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @journal_types }
    end
  end

  # GET /journal_types/1
  # GET /journal_types/1.json
  def show
    @journal_type = JournalType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @journal_type }
    end
  end

  # GET /journal_types/new
  # GET /journal_types/new.json
  def new
    @journal_type = JournalType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @journal_type }
    end
  end

  # GET /journal_types/1/edit
  def edit
    @journal_type = JournalType.find(params[:id])
  end

  # POST /journal_types
  # POST /journal_types.json
  def create
    @journal_type = JournalType.new(journal_type_params)

    respond_to do |format|
      if @journal_type.save
        format.html { redirect_to @journal_type, notice: 'Rodzaj książki utworzony.' }
        format.json { render json: @journal_type, status: :created, location: @journal_type }
      else
        format.html { render action: "new" }
        format.json { render json: @journal_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /journal_types/1
  # PUT /journal_types/1.json
  def update
    @journal_type = JournalType.find(params[:id])

    respond_to do |format|
      if @journal_type.update(journal_type_params)
        format.html { redirect_to @journal_type, notice: 'Zmiany zapisane.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @journal_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /journal_types/1
  # DELETE /journal_types/1.json
  def destroy
    @journal_type = JournalType.find(params[:id])
    @journal_type.destroy

    respond_to do |format|
      format.html { redirect_to journal_types_url }
      format.json { head :ok }
    end
  end

  private

  def journal_type_params
    if params[:journal_type]
      params.require(:journal_type).permit(:name)
    end
  end
end
