# encoding: utf-8
class AuditsController < ApplicationController

  include Pagy::Backend

  # GET /audits
  def index
    authorize! :view, @audits

    @audits_all = Audit.newest_first

    @pagy, @audits = pagy(@audits_all, page: params[:page])

  end

end
