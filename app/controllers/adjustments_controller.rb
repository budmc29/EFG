class AdjustmentsController < ApplicationController
  before_filter :verify_view_permission
  before_filter :load_loan, only: :index

  def index
    @loan_adjustments = LoanAdjustmentPresenter.for_loan(@loan)
  end

  private

  def load_loan
    @loan = current_lender.loans.find(params[:loan_id])
  end

  def verify_view_permission
    enforce_view_permission(Adjustment)
  end
end
