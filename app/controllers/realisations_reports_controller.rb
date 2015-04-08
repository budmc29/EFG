class RealisationsReportsController < ApplicationController
  before_action :verify_create_permission

  def new
    @realisations_report = RealisationsReport.new(current_user, {})
  end

  def create
    @realisations_report = RealisationsReport.new(current_user, params[:realisations_report])

    if @realisations_report.valid?
      respond_to do |format|
        format.html { render :summary }
        format.csv do
          filename = "#{Date.current.to_s(:db)}_realisations_report.csv"
          csv_export = RealisationsReportCsvExport.new(@realisations_report.realisations)
          stream_response(csv_export, filename)
        end
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
