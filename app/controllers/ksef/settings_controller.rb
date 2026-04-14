class Ksef::SettingsController < Ksef::BaseController
  before_action :require_superadmin
  before_action :throttle_manual_sync, only: :sync

  def edit
  end

  def update
    if @ksef_setting.update(setting_params)
      redirect_to edit_ksef_setting_path, notice: "Konfiguracja KSeF zaktualizowana."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def sync
    unless @ksef_setting.configured?
      redirect_to edit_ksef_setting_path, alert: "Najpierw uzupełnij NIP, certyfikat i klucz prywatny."
      return
    end

    Ksef::SyncJob.perform_later
    redirect_to edit_ksef_setting_path, notice: "Synchronizacja KSeF została uruchomiona."
  end

  private

  def throttle_manual_sync
    cache_key = "ksef_manual_sync:#{current_user.id}"
    last_triggered = Rails.cache.read(cache_key)
    if last_triggered && last_triggered > 1.minute.ago
      redirect_to edit_ksef_setting_path, alert: "Synchronizację można uruchomić raz na minutę." and return
    end
    Rails.cache.write(cache_key, Time.current, expires_in: 2.minutes)
  end

  def require_superadmin
    return if current_user.is_superadmin
    redirect_to root_path, alert: I18n.t(:"unauthorized.default")
  end

  def setting_params
    attrs = params.require(:ksef_setting).permit(:nip, :api_url, :cert_pem, :key_pem, :key_passphrase)
    attrs.delete(:key_passphrase) if attrs[:key_passphrase].blank?
    attrs.delete(:cert_pem) if attrs[:cert_pem].blank?
    attrs.delete(:key_pem) if attrs[:key_pem].blank?
    attrs
  end
end
