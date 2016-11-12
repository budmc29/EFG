class RepaymentDuration
  CREATED_FROM_TRANSFER_MIN_MONTHS = 0
  DEFAULT_MIN_LOAN_TERM_MONTHS_SFLG = 24

  attr_reader :loan, :loan_category

  delegate :maturity_date, to: :loan

  def initialize(loan)
    @loan = loan
    @loan_category = loan.loan_category
  end

  def min_months
    if loan.created_from_transfer?
      CREATED_FROM_TRANSFER_MIN_MONTHS
    elsif loan.sflg? || loan.legacy_loan?
      DEFAULT_MIN_LOAN_TERM_MONTHS_SFLG
    else
      repayment_duration_constraints.min
    end
  end

  def max_months
    repayment_duration_constraints.max
  end

  def months_between_draw_date_and_maturity_date
    month_count         = 1 # count the initial draw month
    comparison_date     = initial_draw_date = loan.initial_draw_date
    comparison_end_date = maturity_date.prev_month

    # count the number of months between initial draw date and one month prior to maturity date
    until comparison_date.year == comparison_end_date.year && comparison_date.month == comparison_end_date.month
      comparison_date = comparison_date.next_month
      month_count += 1
    end

    # only count the last month if its maturity day number is after the initial draw day number
    # (e.g. draw day 20th, maturity day 21st)
    if maturity_date.day > initial_draw_date.day
      month_count += 1
    end

    month_count
  end

  private
    def repayment_duration_constraints
      loan.rules.loan_category_repayment_duration(loan.loan_category_id)
    end
end
