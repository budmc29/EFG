class LoanAlertsController < ApplicationController
  ALERTS = {
    "not_closed"     => LoanAlerts::NotClosed,
    "not_demanded"   => LoanAlerts::NotDemanded,
    "not_drawn"      => LoanAlerts::NotDrawn,
    "not_progressed" => LoanAlerts::NotProgressed,
  }.freeze

  before_filter :verify_view_permission

  helper_method :alert_type

  def show
    klass = ALERTS.fetch(alert_type) { raise ActiveRecord::RecordNotFound }
    @alert = klass.new(current_lender)
    @group = @alert.group(params[:priority])

    respond_to do |format|
      format.html
      format.csv do
        csv_export = LoanCsvExport.new(@group)
        stream_response(csv_export, csv_filename)
      end
    end
  end

  private

  def alert_type
    params[:id]
  end

  def csv_filename
    "#{[alert_type, @group.priority].reject(&:blank?).join('-')}.csv"
  end

  def verify_view_permission
    enforce_view_permission(LoanAlerts)
  end
end
