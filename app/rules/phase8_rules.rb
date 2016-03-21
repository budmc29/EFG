class Phase8Rules < Phase7Rules
  def self.claim_limit_calculator
    Phase8ClaimLimitCalculator
  end

  def self.maximum_allowed_turnover
    Money.new(41_000_000_00)
  end
end
