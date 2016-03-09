class RealisationAdjustmentsController < ApplicationController
  before_filter :verify_create_permission, only: [:new, :create]
  before_filter :load_loan, only: [:new, :create]

  def new
    @realisation_adjustment = LoanRealisationAdjustment.new(@loan)
  end

  def create
    @realisation_adjustment = LoanRealisationAdjustment.new(@loan, params[:realisation_adjustment])
    @realisation_adjustment.created_by = current_user

    if @realisation_adjustment.save
      flash[:notice] = I18n.t("realisation_adjustments.adjustment_saved")
      redirect_to loan_url(@loan)
    else
      render :new
    end
  end

  private
  def verify_create_permission
    enforce_create_permission(RealisationAdjustment)
  end

  def load_loan
    @loan = Loan.find(params[:loan_id])
  end
end
