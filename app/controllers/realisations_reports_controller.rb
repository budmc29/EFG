class RealisationsReportsController < ApplicationController
  before_action :verify_create_permission

  def new
    @realisations_report = RealisationsReportPresenter.new(current_user, {})
  end

  def create
    @realisations_report = RealisationsReportPresenter.new(current_user, params[:realisations_report_presenter])
    if @realisations_report.valid?
      respond_to do |format|
        format.html { render :summary }
        format.csv { render text: @realisations_report.to_csv, content_type: 'text/csv' }
      end
    else
      respond_to do |format|
        format.html { render :new }
      end
    end
  end

  private

  def verify_create_permission
    enforce_create_permission(RealisationsReport)
  end

end