class UsersController < ApplicationController
  load_and_authorize_resource

  # GET /users
  def index
  end

  # GET /users/1
  def show
  end

  # GET /users/1/edit
  def edit
  end

  # PUT /users/1
  def update
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
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :ok }
    end
  end
end

