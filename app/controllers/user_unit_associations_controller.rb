# encoding: utf-8
class UserUnitAssociationsController < ApplicationController
  load_and_authorize_resource

  def show
  end

  def new
  end

  def create
    respond_to do |format|
      if @user_unit_association.save
        format.html { redirect_to @user_unit_association.user, notice: 'Użytkownik przypisany do jednostki.' }
        format.json { render json: @user_unit_association, status: :created, location: @user_unit_association }
      else
        format.html { render action: "new" }
        format.json { render json: @user_unit_association.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @user_unit_association.update_attributes(params[:user_unit_association])
        format.html { redirect_to @user_unit_association.user, notice: 'Zmiany zapisane.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @user_unit_association.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    unit = @user_unit_association.unit
    @user_unit_association.destroy

    respond_to do |format|
      format.html { redirect_to unit }
      format.json { head :ok }
    end
  end
end
