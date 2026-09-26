require 'test_helper'

class JournalGrantTest < ActiveSupport::TestCase
  test "fixtures should have at most one initial balance per journal and grant" do
    duplicates = JournalGrant.group(:journal_id, :grant_id).having("count(*) > 1").count
    assert_empty duplicates, "duplicate (journal_id, grant_id) pairs in journal_grants fixtures: #{duplicates.keys.inspect}"
  end

  test "fixtures should be valid and point to existing journals and grants" do
    assert_not_empty JournalGrant.all
    JournalGrant.all.each do |journal_grant|
      assert journal_grant.valid?, "journal_grant #{journal_grant.id}: #{journal_grant.errors.full_messages.join(', ')}"
      assert_not_nil journal_grant.journal, "journal_grant #{journal_grant.id} points to a missing journal"
      assert_not_nil journal_grant.grant, "journal_grant #{journal_grant.id} points to a missing grant"
    end
  end

  test "should not allow two initial balances for the same journal and grant" do
    existing = JournalGrant.first
    duplicate = JournalGrant.new(:journal => existing.journal, :grant => existing.grant, :initial_grant_balance => 1)

    assert_not duplicate.valid?
    assert_includes duplicate.errors.attribute_names, :journal_id
  end
end
