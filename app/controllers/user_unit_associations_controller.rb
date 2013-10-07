# encoding: utf-8
class UserUnitAssociationsController < ApplicationController

  def show
    @user_unit_association = UserUnitAssociation.find(params[:id])
    authorize! :read, @user_unit_association
  end

  def edit
    @user_unit_association = UserUnitAssociation.find(params[:id])
    authorize! :update, @user_unit_association
  end

  def update
    @user_unit_association = UserUnitAssociation.find(params[:id])
    authorize! :update, @user_unit_association

    respond_to do |format|
      if @user_unit_association.update_attributes(params[:user_unit_association])
        format.html { redirect_to params[:from] == "unit" ? @user_unit_association.unit : @user_unit_association.user, notice: 'Zmiany zapisane.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @user_unit_association.errors, status: :unprocessable_entity }
      end
    end
  end

  def new
    @user_unit_association = UserUnitAssociation.new
    if (params[:user_id])
      @user_unit_association.user = User.find(params[:user_id])
      @units = current_user.find_units.reject { |u| @user_unit_association.user.units.include?(u) }
    elsif (params[:unit_id])
      @user_unit_association.unit = Unit.find(params[:unit_id])
      @users = current_user.users_to_manage.reject { |u| @user_unit_association.unit.users.include?(u) }
      @user_unit_association.user = @users.first
    end
    authorize! :create, @user_unit_association
  end

  def create
    @user_unit_association = UserUnitAssociation.new(params[:user_unit_association])
    authorize! :create, @user_unit_association
    
    respond_to do |format|
      if @user_unit_association.save
        format.html { redirect_to params[:from] == "unit" ? @user_unit_association.unit : @user_unit_association.user, notice: 'Użytkownik przypisany do jednostki.' }
        format.json { render json: @user_unit_association, status: :created, location: @user_unit_association }
      else
        format.html { render action: "new" }
        format.json { render json: @user_unit_association.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user_unit_association = UserUnitAssociation.find(params[:id])
    authorize! :destroy, @user_unit_association

    user = @user_unit_association.user
    unit = @user_unit_association.unit
    @user_unit_association.destroy

    respond_to do |format|
      format.html { redirect_to params[:from] == "unit" ? unit : user }
      format.json { head :ok }
    end
  end
end
