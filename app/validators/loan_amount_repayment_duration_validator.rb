class LoanAmountRepaymentDurationValidator < Validator
  FIVE_YEARS = 60
  ONE_POINT_TWO_MILLION = Money.new(1_200_000_00)
  SIX_HUNDRED_THOUSAND = Money.new(600_000_00)

  def validate
    if amount > ONE_POINT_TWO_MILLION
      add_error(:amount, :maximum_amount)
    elsif amount > SIX_HUNDRED_THOUSAND && repayment_duration > FIVE_YEARS
      add_error(:repayment_duration, :maximum_five_year_amount)
    end
  end

  private
    delegate :amount, :repayment_duration, to: :object
end
