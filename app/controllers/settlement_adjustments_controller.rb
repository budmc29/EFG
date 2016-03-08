class SettlementAdjustmentsController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :create]
  before_filter :load_loan, only: [:new, :create]

  def new
    @settlement_adjustment = LoanSettlementAdjustment.new(@loan)
  end

  def create
    @settlement_adjustment = LoanSettlementAdjustment.new(
      @loan, params[:loan_settlement_adjustment]
    )
    @settlement_adjustment.created_by = current_user

    if @settlement_adjustment.save
      redirect_to loan_url(@loan)
    else
      render :new
    end
  end

  private

  def verify_create_permission
    enforce_create_permission(SettlementAdjustment)
  end

  def load_loan
    @loan = current_lender.loans.find(params[:loan_id])
  end
end
