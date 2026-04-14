module Ksef
  class SyncJob < ApplicationJob
    queue_as :default

    limits_concurrency to: 1, key: "ksef_sync" if respond_to?(:limits_concurrency)

    retry_on StandardError, wait: :polynomially_longer, attempts: 3

    discard_on StandardError do |job, error|
      Rails.logger.error("KSeF SyncJob permanently failed after retries: #{error.class}: #{error.message}")
      KsefMailer.sync_failed(error).deliver_later
    end

    def perform
      Ksef::Sync.call
    end
  end
end
