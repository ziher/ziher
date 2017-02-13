# encoding: utf-8
class AuditsController < ApplicationController

  # GET /audits
  def index
    @audits = Audit.newest_first.page(params[:page])
  end

end
