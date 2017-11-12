class InventorySourcesController < ApplicationController
  # GET /inventory_sources
  # GET /inventory_sources.json
  def index
    @inventory_sources = InventorySource.all
    authorize! :read, InventorySource

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @inventory_sources }
    end
  end

  # GET /inventory_sources/1
  # GET /inventory_sources/1.json
  def show
    @inventory_source = InventorySource.find(params[:id])
    authorize! :read, @inventory_source

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @inventory_source }
    end
  end

  # GET /inventory_sources/new
  # GET /inventory_sources/new.json
  def new
    @inventory_source = InventorySource.new
    authorize! :create, @inventory_source

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @inventory_source }
    end
  end

  # GET /inventory_sources/1/edit
  def edit
    @inventory_source = InventorySource.find(params[:id])
    authorize! :update, @inventory_source
  end

  # POST /inventory_sources
  # POST /inventory_sources.json
  def create
    @inventory_source = InventorySource.new(inventory_source_params)
    authorize! :create, @inventory_source

    respond_to do |format|
      if @inventory_source.save
        format.html { redirect_to @inventory_source, notice: 'Inventory source was successfully created.' }
        format.json { render json: @inventory_source, status: :created, location: @inventory_source }
      else
        format.html { render action: "new" }
        format.json { render json: @inventory_source.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /inventory_sources/1
  # PUT /inventory_sources/1.json
  def update
    @inventory_source = InventorySource.find(params[:id])
    authorize! :update, @inventory_source

    flash.now[:alert] = @inventory_source.errors.values.join("<br/>")
    flash.keep

    respond_to do |format|
      if @inventory_source.update_attributes(inventory_source_params)
        format.html { redirect_to @inventory_source, notice: 'Inventory source was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @inventory_source.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /inventory_sources/1
  # DELETE /inventory_sources/1.json
  def destroy
    @inventory_source = InventorySource.find(params[:id])
    authorize! :destroy, @inventory_source
    @inventory_source.destroy

    flash.now[:alert] = @inventory_source.errors.values.join("<br/>")
    flash.keep

    respond_to do |format|
      format.html { redirect_to inventory_sources_url }
      format.json { head :no_content }
    end
  end

  private

  def inventory_source_params
    if params[:inventory_source]
      params.require(:inventory_source).permit(:is_active, :name)
    end
  end
end
