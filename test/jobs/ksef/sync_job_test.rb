require 'test_helper'
require 'minitest/mock'

class Ksef::SyncJobTest < ActiveJob::TestCase
  test "calls Ksef::Sync.call" do
    called = false
    Ksef::Sync.stub(:call, ->(*) { called = true }) do
      Ksef::SyncJob.perform_now
    end
    assert called
  end
end
