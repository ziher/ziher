module Ksef
  class SyncJob < ApplicationJob
    queue_as :default

    limits_concurrency to: 1, key: "ksef_sync" if respond_to?(:limits_concurrency)

    def perform
      Ksef::Sync.call
    end
  end
end
