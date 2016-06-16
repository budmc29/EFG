class LumpSumRepaymentLoanChange < LoanChangePresenter
  attr_reader :lump_sum_repayment
  attr_accessible :lump_sum_repayment

  validate :validate_lump_sum_repayment
  validate :validate_outstanding_balance

  before_save :update_loan_change

  def lump_sum_repayment=(value)
    @lump_sum_repayment = value.present? ? Money.parse(value) : nil
  end

  private

    def update_loan_change
      loan_change.change_type = ChangeType::LumpSumRepayment
      loan_change.lump_sum_repayment = lump_sum_repayment
    end

    def validate_lump_sum_repayment
      if lump_sum_repayment.nil?
        errors.add(:lump_sum_repayment, :required)
      elsif lump_sum_repayment <= 0
        errors.add(:lump_sum_repayment, :must_be_gt_zero)
      elsif total_lump_sum_repayments > loan.cumulative_drawn_amount
        errors.add(:lump_sum_repayment, :exceeds_amount_drawn)
      end
    end

    def validate_outstanding_balance
      if total_lump_sum_repayments + initial_draw_amount > loan.cumulative_drawn_amount
        errors.add(:initial_draw_amount, :exceeds_amount_remaining)
      end
    end

    def total_lump_sum_repayments
      loan.cumulative_lump_sum_amount + (lump_sum_repayment || Money.new(0))
    end
end
