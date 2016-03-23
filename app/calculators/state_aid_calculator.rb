class StateAidCalculator
  RISK_FACTOR = 0.3

  def initialize(loan)
    @loan = loan
  end

  def state_aid_eur
    euro = state_aid_gbp * euro_conversion_rate
    Money.new(euro.cents, 'EUR')
  end

  private
    attr_reader :loan

    def amount
      loan.amount
    end

    def euro_conversion_rate
      loan.euro_conversion_rate
    end

    def guarantee_rate
      loan.guarantee_rate
    end

    def premium_schedule
      loan.premium_schedule
    end

    def state_aid_gbp
      (amount * (guarantee_rate / 100) * RISK_FACTOR) - total_premiums
    end

    def total_premiums
      premium_schedule.total_premiums
    end
end
