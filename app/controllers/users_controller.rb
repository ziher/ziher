# encoding: utf-8
class UsersController < ApplicationController

  # GET /users
  def index
    unless current_user.can_manage_any_user
      redirect_to root_path, alert: 'Brak użytkowników do zarządzania'
      return
    end

    @users = current_user.users_to_manage

    respond_to do |format|
      format.html { # show.html.erb
        @csv_export_link = users_path(:format => :csv)
      }
      format.csv {
        @users = current_user.users_to_manage

        filename = "ZiHeR_lista_uzytkownikow_#{Time.now.strftime("%Y%m%d")}.csv"

        response.headers['Content-Type'] = 'text/csv'
        response.headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""

        render template: 'users/index'
      }
    end
  end

  # GET /users/1
  def show
    @user = User.find(params[:id])
    authorize! :read, @user
  end

  def new
    @user = User.new
  end

  # POST /users
  def create
    @user = User.new(user_params)
    authorize! :create, @user
    authorize! :set_superadmin, @user if params[:user][:set_superadmin]

    respond_to do |format|
      if @user.save
        @user.invite!(current_user)
        format.html { redirect_to @user, notice: 'Użytkownik utworzony - wysłano email z zaproszeniem.' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
    authorize! :update, @user
  end

  # PUT /users/1
  def update
    @user = User.find(params[:id])
    authorize! :update, @user
    authorize! :set_superadmin, @user if params[:user][:set_superadmin]

    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'Zmiany zapisane.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    authorize! :delete, @user

    @user.destroy

    if not @user.errors.values.blank?
      flash.now[:user] = @user.errors.values.join("<br/>")
    end
    flash.keep

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :ok }
    end
  end

  # Blocks user
  def block
    @user = User.find(params[:id])
    authorize! :update, @user
    
    @user.is_blocked = true
    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'Użytkownik zablokowany.' }
        format.json { head :ok }
      else
        format.html { render action: "show" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def unblock
    @user = User.find(params[:id])
    authorize! :update, @user
    
    @user.is_blocked = false
    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'Użytkownik odblokowany.' }
        format.json { head :ok }
      else
        format.html { render action: "show" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def promote
    @user = User.find(params[:id])
    authorize! :update, @user
    
    @user.is_superadmin = true
    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'Użytkownik awansowany na superadmina.' }
        format.json { head :ok }
      else
        format.html { render action: "show" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def demote
    @user = User.find(params[:id])
    authorize! :update, @user
    
    @user.is_superadmin = false
    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'Użytkownik pozbawiony roli superadmina.' }
        format.json { head :ok }
      else
        format.html { render action: "show" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def user_params
    if params[:user]
      params.require(:user).permit(:email, :password, :password_confirmation, :remember_me, :is_superadmin,
                                   :confirmed_at, :confirmation_sent_at, :units, :unit_ids, :groups, :group_ids,
                                   :is_blocked, :first_name, :last_name, :phone)
    end
  end

end
