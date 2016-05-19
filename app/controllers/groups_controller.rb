class GroupsController < ApplicationController
  # GET /groups
  # GET /groups.json
  def index
    unless current_user.can_manage_any_group
      redirect_to root_path, alert: 'Brak grup do zarządzania'
      return
    end

    @groups = Group.find_by_user(current_user, {:can_manage_groups => true})

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @groups }
    end
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
    @group = Group.find(params[:id])
    authorize! :read, @group

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @group }
    end
  end

  # GET /groups/1/edit
  def edit
    @group = Group.find(params[:id])
    authorize! :update, @group

    @subgroups = current_user.groups_to_manage.reject { |g| g.id == @group.id }
    @units = current_user.find_units
  end

  # PUT /groups/1
  # PUT /groups/1.json
  def update
    @group = Group.find(params[:id])
    authorize! :update, @group

    respond_to do |format|
      if @group.update_attributes(group_params)
        format.html { redirect_to @group, notice: 'Group was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /groups/new
  # GET /groups/new.json
  def new
    @group = Group.new

    @supergroups = current_user.groups_to_manage
    @supergroup = @supergroups.first
    @subgroups = current_user.groups_to_manage
    @units = current_user.find_units

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @group }
    end
  end

  # POST /groups
  # POST /groups.json
  def create
    supergroup = Group.find(params[:supergroup_id])
    authorize! :update, supergroup
    
    @group = Group.new(group_params)
    if (@group.subgroups.include?(supergroup))
      @group.subgroups.delete(supergroup)
    end
    
    respond_to do |format|
      if @group.save
        supergroup.subgroups << @group
        format.html { redirect_to @group, notice: 'Group was successfully created.' }
        format.json { render json: @group, status: :created, location: @group }
      else
        format.html { render action: "new" }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    @group = Group.find(params[:id])
    authorize! :destroy, @group

    @group.destroy

    respond_to do |format|
      format.html { redirect_to groups_url }
      format.json { head :ok }
    end
  end

  def group_params
    if params[:group]
      params.require(:group).permit(:name)
    end
  end

end
