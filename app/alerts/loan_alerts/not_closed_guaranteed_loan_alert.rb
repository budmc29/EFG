# EFG loans
# if state ‘guaranteed’ and maturity date elapsed by 3 months – auto remove
class LoanAlerts::NotClosedGuaranteedLoanAlert < LoanAlerts::LoanAlert
  def loans
    super do |loans|
      loans.
        with_scheme("efg").
        guaranteed.
        maturity_date_between(alert_range.first, alert_range.end)
    end
  end

  def self.start_date
    3.months.ago.to_date
  end

  def self.date_method
    :maturity_date
  end
end
