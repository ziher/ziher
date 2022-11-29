class CategoriesController < ApplicationController
  # GET /categories
  # GET /categories.json
  def index
    authorize! :manage, Category

    @years = Category.get_all_years()

    @grants = Grant.all

    unless params[:year].blank?
      @year = params[:year].to_i
    else
      @year = session[:current_year]
    end

    unless @year and @years.include?(@year)
      @year = @years.last
    end

    session[:current_year] = @year

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @categories }
    end
  end

  # GET /categories/1
  # GET /categories/1.json
  def show
    @category = Category.find(params[:id])
    authorize! :show, @category

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @category }
    end
  end

  # GET /categories/new
  # GET /categories/new.json
  def new
    @category = Category.new
    authorize! :create, @category

    unless params[:is_expense].blank?
      @category.is_expense = params[:is_expense].eql?("true")
    end

    @category.year = session[:current_year]

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @category }
    end
  end

  # GET /categories/1/edit
  def edit
    @category = Category.find(params[:id])
    authorize! :update, @category
  end

  # POST /categories
  # POST /categories.json
  def create
    @category = Category.new(category_params)
    authorize! :create, @category

    respond_to do |format|
      if @category.save
        format.html { redirect_to categories_url, notice: 'Kategoria utworzona.' }
        format.json { render json: @category, status: :created, location: @category }
      else
        format.html { render action: "new" }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /categories/1
  # PUT /categories/1.json
  def update
    @category = Category.find(params[:id])
    authorize! :update, @category

    respond_to do |format|
      if @category.update_attributes(category_params)
        format.html { redirect_to categories_url, notice: 'Zmiany zapisane.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.json
  def destroy
    @category = Category.find(params[:id])
    authorize! :destroy, @category
    @category.destroy

    if not @category.errors.values.blank?
      flash.now[:category] = @category.errors.values.join("<br/>")
    end
    flash.keep

    respond_to do |format|
      format.html { redirect_to categories_url }
      format.json { head :ok }
    end
  end

  def sort
    authorize! :manage, Category

    params['category'].each_with_index do |category_id, position|
      category = Category.find(category_id)
      category.position = position
      category.save
    end

    head :ok
  end

  private

  def category_params
    if params[:category]
      params.require(:category).permit(:name, :is_expense, :position, :year, :is_one_percent)
    end
  end
end
