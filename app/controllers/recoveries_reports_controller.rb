class RecoveriesReportsController < ApplicationController
  before_action :verify_create_permission

  def new
    @recoveries_report = RecoveriesReportPresenter.new(current_user, {})
  end

  def create
    @recoveries_report = RecoveriesReportPresenter.new(current_user, params[:recoveries_report_presenter])
    if @recoveries_report.valid?
      respond_to do |format|
        format.html do
          render :summary
        end
        format.csv do
          filename = "#{Date.current.to_s(:db)}_recovoeries_report.csv"
          csv_export = RecoveriesReportCsvExport.new(@recoveries_report.recoveries)
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
    enforce_create_permission(RecoveriesReport)
  end

end