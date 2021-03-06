class PremiumSchedulesController < ApplicationController
  before_filter :verify_update_permission, only: [:edit, :update]
  before_filter :verify_view_permission, only: [:show]

  before_filter :load_loan
  before_filter :load_premium_schedule, only: [:edit, :update]

  def edit
    unless @premium_schedule.repayment_frequency
      flash[:notice] = I18n.t('premium_schedule.repayment_frequency_not_set')
      redirect_to new_loan_entry_path(@loan)
    end
  end

  def show
    @premium_schedule = @loan.premium_schedule
  end

  def update
    @premium_schedule.attributes = params[:premium_schedule]
    @premium_schedule.calc_type = PremiumSchedule::SCHEDULE_TYPE

    if @premium_schedule.save_and_update_loan_state_aid
      redirect_to leave_premium_schedule_path(@loan)
    else
      render :edit
    end
  end

  private
  def load_loan
    @loan = current_lender.loans.find(params[:loan_id])
  end

  def load_premium_schedule
    @premium_schedule = @loan.premium_schedule ||
                        PremiumSchedule.from_loan(@loan)
  end

  helper_method :leave_premium_schedule_path

  def leave_premium_schedule_path(loan)
    if params[:redirect] == 'loan_entry'
      new_loan_entry_path(loan)
    elsif params[:redirect] == 'transferred_loan_entry'
      new_loan_transferred_entry_path(loan)
    elsif params[:redirect] == 'loan_guarantee'
      new_loan_guarantee_path(loan)
    elsif params[:redirect] == 'loan_offer'
      new_loan_offer_path(loan)
    else
      loan_premium_schedule_path(loan)
    end
  end

  def verify_update_permission
    enforce_update_permission(PremiumSchedule)
  end

  def verify_view_permission
    enforce_view_permission(PremiumSchedule)
  end
end
