class LoanAlertsController < ApplicationController
  ALERTS = {
    "not_closed"     => LoanAlerts::NotClosedLoanAlert,
    "not_demanded"   => LoanAlerts::NotDemandedLoanAlert,
    "not_drawn"      => LoanAlerts::NotDrawnLoanAlert,
    "not_progressed" => LoanAlerts::NotProgressedLoanAlert,
  }.freeze

  before_filter :verify_view_permission

  def show
    klass = ALERTS.fetch(alert_type) { raise ActiveRecord::RecordNotFound }
    @alerting_loans = klass.new(current_lender, params[:priority])

    respond_to do |format|
      format.html
      format.csv do
        csv_export = LoanCsvExport.new(@alerting_loans)
        stream_response(csv_export, csv_filename)
      end
    end
  end

  private

  def alert_type
    params[:id]
  end

  def csv_filename
    "#{[alert_type, @alerting_loans.priority].reject(&:blank?).join('-')}.csv"
  end

  def verify_view_permission
    enforce_view_permission(LoanAlerts)
  end
end
