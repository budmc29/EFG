class Phase8Rules < Phase7Rules
  LOAN_CATEGORY_PREMIUM_RATES = {
    1 => BigDecimal.new("2.0"),
    2 => BigDecimal.new("2.0"),
    3 => BigDecimal.new("2.0"),
    4 => BigDecimal.new("2.0"),
    5 => BigDecimal.new("2.0"),
    6 => BigDecimal.new("1.2"),
    7 => BigDecimal.new("2.0"),
    8 => BigDecimal.new("1.2"),
  }.freeze

  def self.maximum_allowed_turnover
    Money.new(41_000_000_00)
  end

  def self.loan_category_premium_rate(category_id)
    LOAN_CATEGORY_PREMIUM_RATES.fetch(category_id)
  end
end
