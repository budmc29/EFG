class Phase1Rules

  LOAN_CATEGORY_REPAYMENT_DURATIONS = {
    nil => 3..120,
    1   => 3..120,
    2   => 3..120,
    3   => 3..120,
    4   => 3..120,
    5   => 3..24,
    6   => 3..36,
    7   => 3..24,
    8   => 3..36
  }

  def self.claim_limit_calculator
    Phase1ClaimLimitCalculator
  end

  def self.eligibility_check_validations
    [
      EligibilityValidator.new,
      AmountValidator.new(minimum: Money.new(1_000_00), maximum: Money.new(1_000_000_00)),
      RepaymentDurationValidator.new
    ]
  end

  def self.loan_category_guarantee_rate
    BigDecimal.new('75.0')
  end

  def self.loan_category_premium_rate(category_id = nil)
    BigDecimal.new('2.0')
  end

  def self.loan_category_repayment_duration(type)
    self::LOAN_CATEGORY_REPAYMENT_DURATIONS.fetch(type)
  end

  def self.loan_entry_validations
    eligibility_check_validations
  end

  def self.premium_schedule_required_for_state_aid_calculation?
    true
  end

  def self.repayment_duration_loan_change_validations
    [
      RepaymentDurationValidator.new
    ]
  end

  def self.state_aid_calculator
    StateAidCalculator
  end

  def self.state_aid_letter
    StateAidLetter
  end

  def self.update_loan_lending_limit_validations
    [
      AmountValidator.new(minimum: Money.new(1_000_00), maximum: Money.new(1_000_000_00)),
      RepaymentDurationValidator.new
    ]
  end

  def self.maximum_allowed_turnover
    Money.new(41_000_000_00)
  end
end
