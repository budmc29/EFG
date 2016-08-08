class RepaymentProfileLoanChange < LoanChangePresenter
  delegate :repayment_frequency, to: :loan

  attr_accessible :repayment_profile, :fixed_repayment_amount

  validates_with RepaymentProfileValidator

  validate :repayment_profile_is_changing

  before_validation :set_repayment_duration

  before_save :set_attributes

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
end
