class RepaymentProfileLoanChange < LoanChangePresenter
  delegate :initial_draw_date,
           :maturity_date,
           :repayment_frequency,
           to: :loan

  attr_accessible :repayment_profile, :fixed_repayment_amount

  validates_with RepaymentProfileValidator

  validate :repayment_profile_is_changing
  validate :new_loan_term_is_allowed

  before_validation :set_repayment_duration

  before_save :set_attributes

  def loan_term_months_so_far
    (next_premium_cheque_date.year * 12 + next_premium_cheque_date.month) -
      (initial_draw_date.year * 12 + initial_draw_date.month)
  end

  private

  def repayment_profile_is_changing
    if loan.repayment_profile ==
       PremiumSchedule::FIXED_TERM_REPAYMENT_PROFILE &&
       repayment_profile == loan.repayment_profile
      errors.add(:repayment_profile, :must_change)
    end
  end

  def set_attributes
    loan_change.change_type = ChangeType::RepaymentProfile
    loan_change.repayment_profile = repayment_profile
    loan_change.old_repayment_profile = loan.repayment_profile
    loan_change.fixed_repayment_amount = fixed_repayment_amount
    loan_change.old_fixed_repayment_amount = loan.fixed_repayment_amount

    loan.repayment_profile = repayment_profile
    loan.fixed_repayment_amount = fixed_repayment_amount
  end

  def set_repayment_duration
    unless repayment_profile == PremiumSchedule::FIXED_AMOUNT_REPAYMENT_PROFILE
      loan_change.repayment_duration ||= 0
      return
    end

    loan_change.repayment_duration = (total_draw_amount / fixed_repayment_amount).floor
  end

  def total_draw_amount
    (initial_draw_amount || Money.new(0)) +
      (second_draw_amount || Money.new(0)) +
      (third_draw_amount || Money.new(0)) +
      (fourth_draw_amount || Money.new(0))
  end

  def new_loan_term_is_allowed
    if loan_change.repayment_duration > max_remaining_months
      errors.add(
        :current_repayment_duration_at_next_premium,
        :exceeds_threshold,
        max_months: repayment_duration_max_months,
        months_so_far: loan_term_months_so_far,
        max_remaining_months: max_remaining_months
      )
    end
  end

  def max_remaining_months
    repayment_duration_max_months - loan_term_months_so_far
  end

  def repayment_duration_max_months
    RepaymentDuration.new(loan).max_months
  end
end
