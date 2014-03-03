# encoding: utf-8
class UsersController < ApplicationController

  # GET /users
  def index
    @users = current_user.users_to_manage
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
    @user = User.new(params[:user])
    authorize! :create, @user
    authorize! :set_superadmin, @user if params[:user][:set_superadmin]

    respond_to do |format|
      if @user.save
        @user.invite!(current_user)
        format.html { redirect_to @user, notice: 'Uzytkownik utworzony.' }
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
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'Zmiany zapisane.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user = User.find(params[:id])
    authorize! :destroy, @user

    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :ok }
    end
  end

	# Blockes user
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
end
