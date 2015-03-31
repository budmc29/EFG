class RealisationReportsController < ApplicationController
  before_action :verify_create_permission

  def new
    @realisation_report = RealisationReportPresenter.new(current_user, {})
  end

  def create
    @realisation_report = RealisationReportPresenter.new(current_user, params[:realisation_report_presenter])
    if @realisation_report.valid?
      respond_to do |format|
        format.html { render :summary }
        format.csv { render text: @realisation_report.to_csv, content_type: 'text/csv' }
      end
    else
      respond_to do |format|
        format.html { render :new }
      end
    end
  end

  private

  def verify_create_permission
    enforce_create_permission(RealisationReport)
  end

end