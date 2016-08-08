class FixedRepaymentAmountOutstandingLoanValue
  def initialize(args)
    @drawdowns = args[:drawdowns]
    @quarter = args[:quarter]
    @repayment_frequency = args[:repayment_frequency]
    @repayment_holiday = args[:repayment_holiday]
    @fixed_repayment_amount = args[:fixed_repayment_amount]
  end

  def amount
    return total_drawn if repayment_holiday_active?

    [outstanding_value, Money.new(0)].max
  end

  private

  attr_reader :drawdowns, :quarter, :repayment_holiday,
              :fixed_repayment_amount, :repayment_frequency

  def total_drawn
    drawdowns.sum(Money.new(0)) do |drawdown|
      drawdown.month > quarter.last_month ? Money.new(0) : drawdown.amount
    end
  end

  def repayment_holiday_active?
    repayment_holiday >= quarter.last_month
  end

  def repayment_months_so_far
    if repayment_frequency == RepaymentFrequency::InterestOnly
      0
    else
      quarter.last_month - total_drawdown_repayment_months - repayment_holiday
    end
  end

  def total_drawdown_repayment_months
    (quarter.last_month % repayment_frequency.months_per_repayment_period)
  end

  def outstanding_value
    total_drawn - (fixed_repayment_amount * repayment_months_so_far)
  end

  def months_per_repayment_period
    if interest_only_repayment_frequency?
      # No repayment until the end of the loan
      0
    else
      repayment_frequency.months_per_repayment_period
    end
  end

  def repayment_holiday
    # If the payment holiday is not a multiple of the repayment frequency, it
    # gets rounded down to the last repayment month. E.g. For a six monthly
    # loan a holiday of 8 months becomes 6 months. For a quarterly loan a
    # holiday of 2 months becomes 0 months.
    return 0 if interest_only_repayment_frequency?

    @repayment_holiday.div(months_per_repayment_period) *
      months_per_repayment_period
  end

  def interest_only_repayment_frequency?
    repayment_frequency == RepaymentFrequency::InterestOnly
  end
end
