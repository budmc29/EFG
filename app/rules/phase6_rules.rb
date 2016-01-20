class Phase6Rules < Phase5Rules

  LOAN_CATEGORY_REPAYMENT_DURATIONS = {
    nil => 3..120,
    1   => 3..120,
    2   => 3..120,
    3   => 3..120,
    4   => 3..120,
    5   => 3..36,
    6   => 3..36,
    7   => 3..36,
    8   => 3..36
  }

  LOAN_CATEGORY_PREMIUM_RATES = {
    1 => BigDecimal.new('2.0'),
    2 => BigDecimal.new('2.0'),
    3 => BigDecimal.new('2.0'),
    4 => BigDecimal.new('2.0'),
    5 => BigDecimal.new('2.0'),
    6 => BigDecimal.new('1.3'),
    7 => BigDecimal.new('2.0'),
    8 => BigDecimal.new('1.3'),
  }

  def self.claim_limit_calculator
    Phase6ClaimLimitCalculator
  end

  def self.eligibility_check_validations
    [
      EligibilityValidator.new,
      AmountValidator.new(minimum: Money.new(1_000_00), maximum: Money.new(1_200_000_00)),
      RepaymentDurationValidator.new,
      Phase6AmountValidator.new
    ]
  end

  def self.loan_category_guarantee_rate
    BigDecimal.new('75.0')
  end

  def self.loan_category_premium_rate(category_id)
    LOAN_CATEGORY_PREMIUM_RATES.fetch(category_id)
  end

  def self.loan_category_repayment_duration(type)
    LOAN_CATEGORY_REPAYMENT_DURATIONS.fetch(type)
  end

  def self.loan_entry_validations
    eligibility_check_validations
  end

  def self.premium_schedule_required_for_state_aid_calculation?
    false
  end

  def self.repayment_duration_loan_change_validations
    [
      RepaymentDurationValidator.new,
      Phase6AmountValidator.new
    ]
  end

  def self.state_aid_calculator
    Phase6StateAidCalculator
  end

  def self.state_aid_letter
    Phase6StateAidLetter
  end

  def self.update_loan_lending_limit_validations
    [
      AmountValidator.new(minimum: Money.new(1_000_00), maximum: Money.new(1_200_000_00)),
      RepaymentDurationValidator.new,
      Phase6AmountValidator.new
    ]
  end

end
