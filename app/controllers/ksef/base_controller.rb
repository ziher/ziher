class Ksef::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :load_setting

  private

  def load_setting
    @ksef_setting = KsefSetting.instance
  end
end
