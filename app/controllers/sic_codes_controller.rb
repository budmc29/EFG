class SicCodesController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :create]
  before_filter :verify_update_permission, only: [:edit, :update]
  before_filter :verify_view_permission, only: [:index]

  def index
    @sic_codes = SicCode.paginate(per_page: 100, page: params[:page])
  end

  def new
    @sic_code = SicCode.new
  end

  def create
    @sic_code = SicCode.new(params[:sic_code])
    if @sic_code.save
      redirect_to sic_codes_path,
                  notice: "SIC code #{@sic_code.code} successfully created"
    else
      render :new
    end
  end

  def edit
    @sic_code = SicCode.find(params[:id])
  end

  def update
    @sic_code = SicCode.find(params[:id])
    @sic_code.attributes = params[:sic_code]
    if @sic_code.save
      redirect_to sic_codes_path,
                  notice: "SIC code #{@sic_code.code} successfully updated"
    else
      render :edit
    end
  end

  private

  def verify_create_permission
    enforce_create_permission(SicCode)
  end

  def verify_update_permission
    enforce_update_permission(SicCode)
  end

  def verify_view_permission
    enforce_view_permission(SicCode)
  end
end
