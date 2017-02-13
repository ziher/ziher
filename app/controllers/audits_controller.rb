# encoding: utf-8
class AuditsController < ApplicationController

  # GET /audits
  def index
    @audits = Audit.descending.page(params[:page])
  end

end
