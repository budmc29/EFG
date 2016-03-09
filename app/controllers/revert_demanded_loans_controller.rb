class RevertDemandedLoansController < ApplicationController
  before_filter :verify_create_permission
  before_filter :load_loan

  rescue_from_incorrect_loan_state_error

  def create
    RevertDemandedLoan.new(@loan).save
    redirect_to(loan_path(@loan))
  end

  private

  def verify_create_permission
    enforce_create_permission(RevertDemandedLoan)
  end

  def load_loan
    @loan = current_lender.loans.find(params[:loan_id])
  end
end
