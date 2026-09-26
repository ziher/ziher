require 'test_helper'

class ItemGrantTest < ActiveSupport::TestCase
  test "fixtures should have at most one grant amount per item and grant" do
    duplicates = ItemGrant.group(:item_id, :grant_id).having("count(*) > 1").count
    assert_empty duplicates, "duplicate (item_id, grant_id) pairs in item_grants fixtures: #{duplicates.keys.inspect}"
  end

  test "fixtures should be valid" do
    ItemGrant.all.each do |item_grant|
      assert item_grant.valid?, "item_grant #{item_grant.id}: #{item_grant.errors.full_messages.join(', ')}"
    end
  end
end
