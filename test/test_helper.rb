ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'test/unit'

class ActiveSupport::TestCase
  include Test::Unit::Assertions

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def assert_unauthorized(msg = nil)
    full_message = build_message(msg, "should not be authorized")
    assert_block(full_message) do
      @response.response_code == 302 and I18n.t(:"unauthorized.default") == flash[:alert]
    end
  end
end

class ActionController::TestCase
  include Devise::TestHelpers
end
