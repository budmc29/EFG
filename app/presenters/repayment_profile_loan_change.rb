class RepaymentProfileLoanChange < LoanChangePresenter
  delegate :initial_draw_date,
           :maturity_date,
           :repayment_frequency,
           to: :loan

  attr_accessible :repayment_profile,
                  :fixed_repayment_amount,
                  :remaining_loan_term

  validates_presence_of :remaining_loan_term, if: :repay_to_zero?
  validates_with RepaymentProfileValidator

  validate :repayment_profile_is_changing
  validate :new_loan_term_is_allowed

  before_validation :set_repayment_duration

  before_save :set_attributes

  def loan_term_months_so_far
    (next_premium_cheque_date.year * 12 + next_premium_cheque_date.month) -
      (initial_draw_date.year * 12 + initial_draw_date.month)
  end

  def remaining_loan_term
    MonthDurationFormatter.format(@remaining_loan_term)
  end

  def remaining_loan_term=(term)
    @remaining_loan_term = MonthDurationFormatter.parse(term)
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

    loan.repayment_profile = repayment_profile
    loan.fixed_repayment_amount = fixed_repayment_amount
    loan.repayment_duration = loan_change.repayment_duration
  end

  def set_repayment_duration
    if repay_to_zero?
      loan_change.repayment_duration = loan_term_months_so_far
      if remaining_loan_term
        loan_change.repayment_duration += remaining_loan_term.total_months
      end
    else
      remaining_duration = (total_draw_amount / fixed_repayment_amount).floor
      loan_change.repayment_duration = loan_term_months_so_far +
                                       remaining_duration
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
        loan_term_validation_error_key,
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

  def loan_term_validation_error_key
    if repay_to_zero?
      :remaining_loan_term
    else
      :current_repayment_duration_at_next_premium
    end
  end
end
