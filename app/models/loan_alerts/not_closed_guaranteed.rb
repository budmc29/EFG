# EFG loans
# if state ‘guaranteed’ and maturity date elapsed by 3 months – auto remove
class LoanAlerts::NotClosedGuaranteed < LoanAlerts::Base
  def loans
    super do |loans|
      loans.
        with_scheme("efg").
        guaranteed.
        maturity_date_between(start_date, end_date)
    end
  end

  def self.start_date
    3.months.ago.to_date
  end

  def start_date
    self.class.start_date
  end

  def date_method
    :maturity_date
  end
end
