class ReprofileDrawsLoanChange < LoanChangePresenter
  LoanAlreadyFullyDrawnError = Class.new(StandardError)

  attr_reader :second_draw_amount, :third_draw_amount, :fourth_draw_amount
  attr_accessor :second_draw_months, :third_draw_months, :fourth_draw_months

  attr_accessible :second_draw_amount, :second_draw_months,
                  :third_draw_amount, :third_draw_months, :fourth_draw_amount,
                  :fourth_draw_months

  before_save :update_loan_change
  before_validation :update_premium_schedule

  validate :no_skipped_draws
  validate :draws_have_months

  def initialize(loan, _)
    raise LoanAlreadyFullyDrawnError if loan.fully_drawn?
    super
  end

  def second_draw_amount=(value)
    @second_draw_amount = value.present? ? Money.parse(value) : nil
  end

  def third_draw_amount=(value)
    @third_draw_amount = value.present? ? Money.parse(value) : nil
  end

  def fourth_draw_amount=(value)
    @fourth_draw_amount = value.present? ? Money.parse(value) : nil
  end

  def current_second_draw_amount
    premium_schedule.second_draw_amount || Money.new(0)
  end

  def current_third_draw_amount
    premium_schedule.third_draw_amount || Money.new(0)
  end

  def current_fourth_draw_amount
    premium_schedule.fourth_draw_amount || Money.new(0)
  end

  private
    def update_loan_change
      loan_change.change_type = ChangeType::ReprofileDraws
    end

    def update_premium_schedule
      premium_schedule.second_draw_amount = second_draw_amount
      premium_schedule.second_draw_months = second_draw_months
      premium_schedule.third_draw_amount  = third_draw_amount
      premium_schedule.third_draw_months  = third_draw_months
      premium_schedule.fourth_draw_amount = fourth_draw_amount
      premium_schedule.fourth_draw_months = fourth_draw_months
    end

    def draws_have_months
      errors.add(:second_draw_months, :required) if second_draw_amount && second_draw_months.blank?
      errors.add(:third_draw_months, :required) if third_draw_amount && third_draw_months.blank?
      errors.add(:fourth_draw_months, :required) if fourth_draw_amount && fourth_draw_months.blank?
    end

    def no_skipped_draws
      if (third_draw_amount or fourth_draw_amount) and not second_draw_amount
        errors.add(:second_draw_amount, :no_skipping)
      end
      errors.add(:third_draw_amount, :no_skipping) if fourth_draw_amount and not third_draw_amount
    end
end
