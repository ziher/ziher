module Ksef
  class SyncRangeJob < ApplicationJob
    queue_as :default

    def perform(date_from:, date_to:)
      Ksef::Sync.call_for_range(
        date_from: Date.parse(date_from),
        date_to:   Date.parse(date_to)
      )
    end
  end
end
