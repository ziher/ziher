class Ksef::SettingsController < Ksef::BaseController
  before_action :require_superadmin

  def edit
  end

  def update
    if @ksef_setting.update(setting_params)
      redirect_to edit_ksef_setting_path, notice: "Konfiguracja KSeF zaktualizowana."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def require_superadmin
    return if current_user.is_superadmin
    redirect_to root_path, alert: I18n.t(:"unauthorized.default")
  end

  def setting_params
    params.require(:ksef_setting).permit(:nip, :api_url, :cert_pem, :key_pem)
  end
end
