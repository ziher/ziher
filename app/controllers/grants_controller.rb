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
      redirect_to grants_url, alert: @grant.errors.full_messages.join("<br/>")
    end
  end

  # POST /grants/1/create_income_category_for_year
  def create_income_category_for_year
    authorize! :manage, Grant

    grant = Grant.find(params[:id])
    year = session[:current_year].to_i

    respond_to do |format|
      if grant.create_income_category_for_year(year)
        format.html { redirect_to categories_url, notice: 'Wpływ dla dotacji ' + grant.name + ' został stworzony.' }
      else
        format.html { redirect_to categories_url, alert: "Błąd tworzenia wpływu dla dotacji " + grant.name + ": " + grant.errors.full_messages.join(', ') }
      end
    end
  end

  # POST /grants/1/delete_income_category_for_year
  def delete_income_category_for_year
    authorize! :manage, Grant

    grant = Grant.find(params[:id])
    year = session[:current_year].to_i

    respond_to do |format|
      if grant.delete_income_category_for_year(year)
        format.html { redirect_to categories_url, notice: 'Wpływ dla dotacji ' + grant.name + ' został usunięty.' }
      else
        format.html { redirect_to journals_url, alert: "Błąd usuwania wpływu dla dotacji " + grant.name + ": " + grant.errors.full_messages.join(', ') }
      end
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
