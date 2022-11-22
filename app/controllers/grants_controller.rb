class GrantsController < ApplicationController
  before_action :set_grant, only: [:show, :edit, :update, :destroy]

  # GET /grants
  def index
    authorize! :manage, Grant

    @grants = Grant.all
  end

  # GET /grants/1
  def show
    authorize! :show, @grant
  end

  # GET /grants/new
  def new
    @grant = Grant.new
    authorize! :create, @grant
  end

  # GET /grants/1/edit
  def edit
    authorize! :update, @grant
  end

  # POST /grants
  def create
    @grant = Grant.new(grant_params)
    authorize! :create, @grant

    if @grant.save
      redirect_to @grant, notice: 'Dodacja została stworzona.'
    else
      render :new
    end
  end

  # PATCH/PUT /grants/1
  def update
    authorize! :update, @grant

    if @grant.update(grant_params)
      redirect_to @grant, notice: 'Dotacja została zaktualizowana.'
    else
      render :edit
    end
  end

  # DELETE /grants/1
  def destroy
    authorize! :destroy, @grant

    if @grant.destroy
      redirect_to grants_url, notice: 'Dotacja została usunięta.'
    else
      redirect_to grants_url, alert: @grant.errors.values.join("<br/>")
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_grant
      @grant = Grant.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def grant_params
      params.require(:grant).permit(:name, :description)
    end
end
