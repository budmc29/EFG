class Phase6ClaimLimitCalculator < ClaimLimitCalculator

  ReducedLoanPercentage = BigDecimal.new('65')
  ReducedLoanCategoryIds = [ 6, 8 ].freeze
  FirstOneHundredThousandPercentage = BigDecimal.new('75')
  AboveOneHundredThousandPercentage = BigDecimal.new('15')

  def cumulative_drawn_amount
    non_reduced_loans_cumulative_draw_amount + reduced_loans_cumulative_draw_amount
  end

  def phase
    Phase.find(6)
  end

  def total_amount
    first_one_hundred_thousand_amount + above_one_hundred_thousand_amount
  end

  private

  def first_one_hundred_thousand_amount
    amount = cumulative_drawn_amount >= Money.new(100_000_00) ? Money.new(100_000_00) : cumulative_drawn_amount
    amount * FirstOneHundredThousandPercentage / 100
  end

  def above_one_hundred_thousand_amount
    if cumulative_drawn_amount > Money.new(100_000_00)
      (cumulative_drawn_amount - Money.new(100_000_00)) * AboveOneHundredThousandPercentage / 100
    else
      Money.new(0)
    end
  end

  def non_reduced_loans_cumulative_draw_amount
    @non_reduced_loans_cumulative_draw_amount ||= begin
      amount = cumulative_drawn_amount_relation
        .where.not(loan_category_id: ReducedLoanCategoryIds)
        .sum(:amount_drawn)

      Money.new(amount)
    end
  end

  def reduced_loans_cumulative_draw_amount
    @reduced_loans_cumulative_draw_amount ||= begin
      amount = cumulative_drawn_amount_relation
        .where(loan_category_id: ReducedLoanCategoryIds)
        .sum(:amount_drawn)

      Money.new(amount) * ReducedLoanPercentage / 100
    end
  end

end
