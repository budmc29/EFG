class AmendCompletedLoansController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :create]
  rescue_from_incorrect_loan_state_error

  def new
    @loan = current_lender.loans.find(params[:loan_id])
    @amend_completed_loan = AmendCompletedLoan.new(@loan)
  end

  def create
    @loan = current_lender.loans.find(params[:loan_id])
    @amend_completed_loan = AmendCompletedLoan.new(@loan)
    @amend_completed_loan.modified_by = current_user
    @amend_completed_loan.save!
    redirect_to(new_loan_entry_path(@amend_completed_loan.new_loan))
  end

  private

  def verify_create_permission
    enforce_create_permission(LoanEntry)
  end
end
