class StatusAmendmentsController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :create]
  rescue_from_incorrect_loan_state_error

  def new
    @loan = current_lender.loans.find(params[:loan_id])
    @loan_status_amendment = LoanStatusAmendment.new(@loan)
  end

  def create
    @loan = current_lender.loans.find(params[:loan_id])
    @loan_status_amendment = LoanStatusAmendment.new(@loan)
    @loan_status_amendment.attributes = params[:loan_status_amendment]
    @loan_status_amendment.modified_by = current_user

    if @loan_status_amendment.save
      flash[:notice] = I18n.t(
        "activemodel.loan_status_amendment.status_amended",
        amendment_type: @loan_status_amendment.status_amendment_type,
      )
      redirect_to loan_url(@loan)
    else
      render :new
    end
  end

  private

  def verify_create_permission
    enforce_create_permission(LoanStatusAmendment)
  end
end
