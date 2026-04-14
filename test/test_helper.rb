ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'webmock/minitest'
WebMock.disable_net_connect!(allow_localhost: true)

class ActiveSupport::TestCase
  fixtures :all

  def assert_unauthorized
    assert @response.response_code == 302 && I18n.t(:"unauthorized.default") == flash[:alert]
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end
