class UnitsController < ApplicationController
  # GET /units
  # GET /units.json
  def index
    unless current_user.can_manage_any_unit
      redirect_to root_path, alert: 'Brak jednostek do zarządzania'
      return
    end

    @units = Unit.find_by_user(current_user)
    @inactive_units = Unit.find_by_user(current_user, false)

    @years = Journal.find_all_years
    @selected_year = params[:year] || session[:current_year]

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @units }
    end
  end

  # GET /units/1
  # GET /units/1.json
  def show
    @unit = Unit.find(params[:id])
    authorize! :read, @unit

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @unit }
    end
  end

  # GET /units/1/edit
  def edit
    @unit = Unit.find(params[:id])
    authorize! :update, @unit
    @groups = Group.find_by_user(current_user, { :can_manage_units => true })
  end

  # PUT /units/1
  # PUT /units/1.json
  def update
    @unit = Unit.find(params[:id])
    authorize! :update, @unit

    respond_to do |format|
      if @unit.update_attributes(unit_params)
        format.html { redirect_to @unit, notice: 'Zmiany zapisane.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @unit.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /units/new
  # GET /units/new.json
  def new
    @unit = Unit.new
    @groups = Group.find_by_user(current_user, { :can_manage_units => true })
    authorize! :create, @unit

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @unit }
    end
  end

  # POST /units
  # POST /units.json
  def create
    @unit = Unit.new(unit_params)
    authorize! :create, @unit

    respond_to do |format|
      if @unit.save
        format.html { redirect_to @unit, notice: 'Jednostka utworzona.' }
        format.json { render json: @unit, status: :created, location: @unit }
      else
        format.html { render action: "new" }
        format.json { render json: @unit.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /units/1/enable
  def enable
    @unit = Unit.find(params[:id])
    authorize! :enable, @unit

    @unit.is_active = true

    respond_to do |format|
      if @unit.save
        format.html { redirect_to @unit, notice: 'Jednostka włączona.' }
      else
        format.html { redirect_to @unit, alert: 'Podczas włączania jednostki nastąpił błąd: ' + @unit.errors }
      end
    end
  end

  # GET /units/1/disable
  def disable
    @unit = Unit.find(params[:id])
    authorize! :disable, @unit

    respond_to do |format|
      if @unit.disable
        format.html { redirect_to @unit, notice: 'Jednostka wyłączona.' }
      else
        format.html { redirect_to @unit, alert: 'Podczas wyłączania nastąpił błąd: ' + @unit.errors.values.join(', ')}
      end
    end
  end

  # DELETE /units/1
  # DELETE /units/1.json
  def destroy
    @unit = Unit.find(params[:id])
    authorize! :destroy, @unit
    # TODO: Unit must not be destroyed if that would change the past years  balance
    # @unit.destroy

    respond_to do |format|
      format.html { redirect_to units_url }
      format.json { head :ok }
    end
  end

  private

  def unit_params
    if params[:unit]
      params.require(:unit).permit(:name, :code, group_ids: [])
    end
  end
end
