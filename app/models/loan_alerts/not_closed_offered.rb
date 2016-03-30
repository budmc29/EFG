# "Legacy or new scheme guaranteed loans – if maturity date has elapsed by 6 months – auto remove
class LoanAlerts::NotClosedOffered < LoanAlerts::Base
  def loans
    super do |loans|
      loans.
        with_scheme("non_efg").
        guaranteed.
        maturity_date_between(start_date, end_date)
    end
  end

  def self.start_date
    6.months.ago.to_date
  end

  def start_date
    self.class.start_date
  end

  def date_method
    :maturity_date
  end
end
