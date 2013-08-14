# encoding: utf-8
class UserGroupAssociationsController < ApplicationController
  load_and_authorize_resource

  def show
  end

  def new
  end

  def create
    respond_to do |format|
      if @user_group_association.save
        format.html { redirect_to @user_group_association.user, notice: 'Użytkownik przypisany do grupy.' }
        format.json { render json: @user_group_association, status: :created, location: @user_group_association }
      else
        format.html { render action: "new" }
        format.json { render json: @user_group_association.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @user_group_association.update_attributes(params[:user_group_association])
        format.html { redirect_to @user_group_association.user, notice: 'Zmiany zapisane.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @user_group_association.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    unit = @user_group_association.unit
    @user_group_association.destroy

    respond_to do |format|
      format.html { redirect_to unit }
      format.json { head :ok }
    end
  end
end
