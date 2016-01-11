class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user!
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  helper_method :func

  ZIHER_VERSION = VERSION[0].to_s + "." + VERSION[1].to_s + "." + VERSION[2].to_s
  ZIHER_COMMIT = VERSION[3].to_s
end
