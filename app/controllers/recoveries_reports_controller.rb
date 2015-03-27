class RecoveriesReportsController < ApplicationController
  before_action :verify_create_permission

  def new
    @recoveries_report = RecoveriesReportPresenter.new(current_user, {})
  end

  def create
    @recoveries_report = RecoveriesReportPresenter.new(current_user, params[:recoveries_report_presenter])
    if @recoveries_report.valid?
      respond_to do |format|
        format.html { render :summary }
        format.csv { render text: @recoveries_report.to_csv, content_type: 'text/csv' }
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