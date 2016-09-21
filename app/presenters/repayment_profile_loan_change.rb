class RepaymentProfileLoanChange < LoanChangePresenter
  delegate :initial_draw_date,
           :maturity_date,
           :repayment_frequency,
           to: :loan

  attr_accessible :repayment_profile,
                  :fixed_repayment_amount,
                  :current_repayment_duration_at_next_premium

  validates_presence_of :current_repayment_duration_at_next_premium,
                        if: :repay_to_zero?

  validates_with RepaymentProfileValidator

  validate :repayment_profile_is_changing
  validate :new_loan_term_is_allowed

  before_validation :set_repayment_duration

  before_save :set_attributes

  def current_repayment_duration_at_next_premium
    MonthDurationFormatter.format(
      @current_repayment_duration_at_next_premium
    )
  end

  def current_repayment_duration_at_next_premium=(duration)
    @current_repayment_duration_at_next_premium =
      MonthDurationFormatter.parse(duration)
  end

  private

  def repay_to_zero?
    repayment_profile == PremiumSchedule::FIXED_TERM_REPAYMENT_PROFILE
  end

  def repayment_profile_is_changing
    if repayment_profile_not_changed?
      errors.add(:repayment_profile, :must_change)
    end
  end

  def repayment_profile_not_changed?
    loan.repayment_profile == PremiumSchedule::FIXED_TERM_REPAYMENT_PROFILE &&
      repayment_profile == loan.repayment_profile
  end

  def set_attributes
    loan_change.change_type = ChangeType::RepaymentProfile
    loan_change.repayment_profile = repayment_profile
    loan_change.old_repayment_profile = loan.repayment_profile
    loan_change.fixed_repayment_amount = fixed_repayment_amount
    loan_change.old_fixed_repayment_amount = loan.fixed_repayment_amount
    loan_change.maturity_date = new_maturity_date
    loan_change.old_maturity_date = loan.maturity_date
    loan_change.old_repayment_duration = loan.repayment_duration.total_months

    loan.repayment_profile = repayment_profile
    loan.fixed_repayment_amount = fixed_repayment_amount
    loan.repayment_duration = loan_change.repayment_duration
    loan.maturity_date = new_maturity_date
  end

  def new_maturity_date
    initial_draw_date.advance(months: loan_change.repayment_duration)
  end

  def set_repayment_duration
    if repay_to_zero?
      loan_change.repayment_duration =
        months_from_loan_start_to_next_premium_collection
      if current_repayment_duration_at_next_premium
        loan_change.repayment_duration +=
          current_repayment_duration_at_next_premium.total_months
      end
    else
      remaining_duration = (total_draw_amount / fixed_repayment_amount).floor
      loan_change.repayment_duration =
        months_from_loan_start_to_next_premium_collection + remaining_duration
    end
  end

  def total_draw_amount
    (initial_draw_amount || Money.new(0)) +
      (second_draw_amount || Money.new(0)) +
      (third_draw_amount || Money.new(0)) +
      (fourth_draw_amount || Money.new(0))
  end

  def new_loan_term_is_allowed
    if loan_change.repayment_duration > repayment_duration_max_months
      errors.add(
        :current_repayment_duration_at_next_premium,
        :exceeds_threshold,
        max_months: repayment_duration_max_months,
        months_so_far: months_from_loan_start_to_next_premium_collection,
        max_remaining_months: max_remaining_months
      )
    end
  end

  def max_remaining_months
    repayment_duration_max_months -
      months_from_loan_start_to_next_premium_collection
  end

  def repayment_duration_max_months
    RepaymentDuration.new(loan).max_months
  end

  def repayment_duration_at_next_premium
    current_repayment_duration_at_next_premium.try(:total_months)
  end
end
