require 'test_helper'

class GroupsControllerTest < ActionController::TestCase
  setup do
    sign_in users(:admin)
    @group = groups(:district_zg_m)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:groups)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create group" do
    assert_difference('Group.count', 1) do
      post :create, group: @group.attributes, supergroup_id: groups(:district_zg).id
    end

    assert_redirected_to group_path(assigns(:group))
  end

  test "should show group" do
    get :show, id: @group.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @group.to_param
    assert_response :success
  end

  test "should update group" do
    put :update, id: @group.to_param, group: @group.attributes
    assert_redirected_to group_path(assigns(:group))
  end

  test "should destroy group" do
    assert_difference('Group.count', -1) do
      delete :destroy, id: @group.to_param
    end

    assert_redirected_to groups_path
  end

  # ########################
  # can_manage_groups = true
  test 'should be able to create group in his supergroup when can_manage_groups is true' do
    #given
    sign_in users(:master_zg)
    user = users(:master_zg)
    supergroup = groups(:district_zg)
    assert user.can_manage_group(supergroup)
    count = Group.count

    #when
    post :create, group: @group.attributes, supergroup_id: supergroup.id

    #then
    assert_equal count + 1, Group.count
    assert_redirected_to group_path(assigns(:group))
  end

  test 'should be able to read group from his supergroup when can_manage_groups is true' do
    #given
    sign_in users(:master_zg)
    user = users(:master_zg)
    supergroup = groups(:district_zg)
    assert user.can_manage_group(supergroup)
    count = Group.count

    #when
    get :show, id: supergroup.subgroups.first.to_param

    #then
    assert_response :success
  end


  test 'should be able to update group from his supergroup when can_manage_groups is true' do
    #given
    sign_in users(:master_zg)
    user = users(:master_zg)
    supergroup = groups(:district_zg)
    subgroup = supergroup.subgroups.first
    assert user.can_manage_group(supergroup)
    count = Group.count

    #when
    put :update, id: subgroup.to_param, group: subgroup.attributes

    #then
    assert_redirected_to group_path()
  end

  test 'should be able to delete group from his supergroup when can_manage_groups is true' do
    #given
    sign_in users(:master_zg)
    user = users(:master_zg)
    supergroup = groups(:district_zg)
    count = Group.count
    assert user.can_manage_group(supergroup)

    #when
    delete :destroy, id: supergroup.subgroups.first.to_param

    #then
    assert_equal count, Group.count + 1
    assert_redirected_to groups_path
  end

  test 'should not be able to crud group not from his supergroup when can_manage_groups is true' do
    #given
    sign_in users(:master_zg)
    user = users(:master_zg)
    supergroup = groups(:district_zg)
    group = groups(:region_d_m)
    count = Group.count
    assert user.can_manage_group(supergroup)
    assert ! user.can_manage_group(group)

    #when
    delete :destroy, id: group.to_param

    #then
    assert_equal count, Group.count
    assert_redirected_to root_path
  end

  test 'should not be able to crud his supergroup when can_manage_groups is true' do
    #given
    sign_in users(:master_zg)
    user = users(:master_zg)
    supergroup = groups(:district_zg)
    count = Group.count
    assert user.can_manage_group(supergroup)

    #when
    delete :destroy, id: supergroup.to_param

    #then
    assert_equal count, Group.count
    assert_redirected_to root_path
  end

  # ########################
  # can_manage_groups = false
  test 'should not be able to crud group from his supergroup when can_manage_groups is false' do
    #given
    sign_in users(:user_zg)
    user = users(:user_zg)
    supergroup = groups(:district_zg)
    count = Group.count
    assert ! user.can_manage_group(supergroup)

    #when
    delete :destroy, id: supergroup.subgroups.first.to_param

    #then
    assert_equal count, Group.count
    assert_redirected_to root_path
  end

  test 'should not be able to crud group not from his supergroup when can_manage_groups is false' do
    sign_in users(:user_zg)
    user = users(:user_zg)
    supergroup = groups(:district_zg)
    group = groups(:region_d_m)
    count = Group.count
    assert ! user.can_manage_group(supergroup)
    # TODO: check if user is in supergroup(this)
    # TODO: check if user is not in supergroup(group)

    #when
    delete :destroy, id: group.to_param

    #then
    assert_equal count, Group.count
    assert_redirected_to root_path
  end

  test 'should not be able to crud his supergroup when can_manage_groups is false' do
    #given
    sign_in users(:user_zg)
    user = users(:user_zg)
    supergroup = groups(:district_zg)
    count = Group.count
    assert ! user.can_manage_group(supergroup)
    # TODO: check if user is in supergroup

    #when
    delete :destroy, id: supergroup.to_param

    #then
    assert_equal count, Group.count
    assert_redirected_to root_path
  end
end