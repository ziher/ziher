class ApplicationController < ActionController::Base
  protect_from_forgery :with => :exception
  before_action :authenticate_user!

  before_action :validate_email
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

  def validate_email
    if current_user != nil and not current_user.valid_email
      flash.now[:email_check] = "<b>Uwaga!</b> Twój adres <b>email jest spoza domeny @zhr.pl lub @malopolska.zhr.pl</b>"
      flash.now[:email_check] += " - <a href='" + edit_user_registration_path + "'>kliknij tu aby go zmienić.</a>"

      flash.now[:email_check] += "</br></br><b>Możliwość logowania</b> adresem email spoza @zhr.pl lub @malopolska.zhr.pl <b>zostanie wyłączona 1 stycznia 2023 roku</b>."
    end
  end
end
