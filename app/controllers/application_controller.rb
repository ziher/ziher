class ApplicationController < ActionController::Base
  protect_from_forgery :with => :exception
  before_action :authenticate_user!
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :func

  ZIHER_VERSION = VERSION[0].to_s + "." + VERSION[1].to_s + "." + VERSION[2].to_s
  ZIHER_COMMIT = VERSION[3].to_s

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [:email, :first_name, :last_name, :phone])
  end

end
