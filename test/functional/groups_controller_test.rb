require 'test_helper'

class GroupsControllerTest < ActionDispatch::IntegrationTest

  setup do
    sign_in users(:admin)
    @group = groups(:district_zg_m)

    @message_unauthorized = I18n.t(:default, :scope => :unauthorized)
  end

  test "should get index" do
    get groups_path
    assert_response :success
    assert_not_nil assigns(:groups)
  end

  test "should get new" do
    get new_group_path
    assert_response :success
  end

  test "should create group" do
    assert_difference('Group.count', 1) do
      # post groups_url, params: {group: @group.attributes, supergroup_id: groups(:district_zg).id}
      post groups_url
    end

    assert_redirected_to group_path(assigns(:group))
  end

  test "should show group" do
    get group_path(@group)
    assert_response :success
  end

  test "should get edit" do
    get edit_group_path(@group)
    assert_response :success
  end

  test "should update group" do
    put group_url(@group), params: {group: {name: "updated"}}
    assert_redirected_to group_path(assigns(:group))
  end

  test "should destroy group" do
    assert_difference('Group.count', -1) do
      delete group_path(@group)
    end

    assert_redirected_to groups_path
  end

  # TODO #60: creating super/subgroups is disabled for now
  # # ########################
  # # can_manage_groups = true
  # test 'should be able to create group in his supergroup when can_manage_groups is true' do
  #   #given
  #   sign_in users(:master_zg)
  #   user = users(:master_zg)
  #   supergroup = groups(:district_zg)
  #   assert user.can_manage_group(supergroup)
  #   count = Group.count
  #
  #   #when
  #   post :create, group: @group.attributes, supergroup_id: supergroup.id
  #
  #   #then
  #   assert_equal count + 1, Group.count
  #   assert_redirected_to group_path(assigns(:group))
  # end

  # TODO #60: creating super/subgroups is disabled for now
  test 'should not be able to create subgroup' do
    #given
    sign_in users(:master_zg)
    user = users(:master_zg)
    supergroup = groups(:district_zg)
    assert user.can_manage_group(supergroup)
    count = Group.count

    @group = groups(:district_po_m)

    #when
    post groups_url, params: {group: {name: "New group", supergroup_id: supergroup.id}}

    #then
    assert_equal count, Group.count
    assert_not_includes supergroup.subgroups, @group
    assert_redirected_to root_path()
  end

  test 'should be able to read group from his supergroup when can_manage_groups is true' do
    #given
    sign_in users(:master_zg)
    user = users(:master_zg)
    supergroup = groups(:district_zg)
    assert user.can_manage_group(supergroup)
    count = Group.count

    #when
    get group_path(supergroup.subgroups.first)

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
    put group_url(subgroup), params: {group: {name: "updated"}}

    #then
    assert_redirected_to group_path
  end

  test 'should be able to delete group from his supergroup when can_manage_groups is true' do
    #given
    sign_in users(:master_zg)
    user = users(:master_zg)
    supergroup = groups(:district_zg)
    count = Group.count
    assert user.can_manage_group(supergroup)

    #when
    delete group_url(supergroup.subgroups.first)

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
    assert ! user.can_manage_group(group.find_all_supergroups.first)

    #when
    post groups_url, params: {group: {name: "New group", supergroup_id: group.find_all_supergroups.first.id}}
    #then
    assert_equal count, Group.count
    assert_equal @message_unauthorized, flash[:alert]
    assert_redirected_to root_path

    #when
    get group_path(group)
    #then
    assert_equal @message_unauthorized, flash[:alert]
    assert_redirected_to root_path

    #when
    put group_url(group), params: {group: {name: "updated"}}
    #then
    assert_equal @message_unauthorized, flash[:alert]
    assert_redirected_to root_path

    #when
    delete group_path(group)
    #then
    assert_equal count, Group.count
    assert_equal @message_unauthorized, flash[:alert]
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
    delete group_path(supergroup)

    #then
    assert_equal count, Group.count
    assert_equal @message_unauthorized, flash[:alert]
    assert_redirected_to root_path
  end

  # ########################
  # can_manage_groups = false
  test 'should not be able to create group in his supergroup when can_manage_groups is false' do
    #given
    sign_in users(:user_zg)
    user = users(:user_zg)
    supergroup = groups(:district_zg)
    assert ! user.can_manage_group(supergroup)
    count = Group.count

    #when
    post groups_url, params: {group: {name: "New group", supergroup_id: supergroup.id}}

    #then
    assert_equal count, Group.count
    assert_equal @message_unauthorized, flash[:alert]
    assert_redirected_to root_path
  end

  test 'should not be able to read his supergroup when can_manage_groups is false' do
    #given
    sign_in users(:user_zg)
    user = users(:user_zg)
    supergroup = groups(:district_zg)
    assert ! user.can_manage_group(supergroup)

    #when
    get group_path(supergroup)

    #then
    assert_equal @message_unauthorized, flash[:alert]
    assert_redirected_to root_path
  end

  test 'should not be able to read group from his supergroup when can_manage_groups is false' do
    #given
    sign_in users(:user_zg)
    user = users(:user_zg)
    supergroup = groups(:district_zg)
    assert ! user.can_manage_group(supergroup)

    #when
    get group_path(supergroup.subgroups.first)

    #then
    assert_equal @message_unauthorized, flash[:alert]
    assert_redirected_to root_path
  end


  test 'should not be able to update group from his supergroup when can_manage_groups is false' do
    #given
    sign_in users(:user_zg)
    user = users(:user_zg)
    supergroup = groups(:district_zg)
    subgroup = supergroup.subgroups.first
    assert ! user.can_manage_group(supergroup)
    count = Group.count

    #when
    put group_path(subgroup), params: {group: {name: "updated"}}

    #then
    assert_equal @message_unauthorized, flash[:alert]
    assert_redirected_to root_path
  end

  test 'should not be able to delete group from his supergroup when can_manage_groups is false' do
    #given
    sign_in users(:user_zg)
    user = users(:user_zg)
    supergroup = groups(:district_zg)
    count = Group.count
    assert ! user.can_manage_group(supergroup)

    #when
    delete group_path(supergroup.subgroups.first)

    #then
    assert_equal count, Group.count
    assert_equal @message_unauthorized, flash[:alert]
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
    delete group_path(group)

    #then
    assert_equal count, Group.count
    assert_equal @message_unauthorized, flash[:alert]
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
    delete group_path(supergroup)

    #then
    assert_equal count, Group.count
    assert_equal @message_unauthorized, flash[:alert]
    assert_redirected_to root_path
  end
end