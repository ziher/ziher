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
      if @user_unit_association.update_attributes(uua_params)
        target = params[:from] == "unit" ? @user_unit_association.unit : @user_unit_association.user

        format.html { redirect_to target, notice: 'Zmiany zapisane.' }
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
    @user_unit_association = UserUnitAssociation.new(uua_params)
    authorize! :create, @user_unit_association

    respond_to do |format|
      if @user_unit_association.save
        target = params[:from] == "unit" ? @user_unit_association.unit : @user_unit_association.user

        format.html { redirect_to target, notice: 'Użytkownik przypisany do jednostki.' }
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
      target = params[:from] == "unit" ? unit : user

      format.html { redirect_to target }
      format.json { head :ok }
    end
  end

  private

  def uua_params
    if params[:user_unit_association]
      params.require(:user_unit_association).permit(:user_id, :unit_id, :can_view_entries, :can_manage_entries,
                                                    :can_close_journals, :can_manage_users)
    end
  end
end
