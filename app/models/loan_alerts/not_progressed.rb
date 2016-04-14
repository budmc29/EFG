# "All schemes, any loan that has remained at the state of
# “eligible” / “incomplete” or “complete”
# – for a period of 6 months from entering those states – should be ‘auto cancelled’"
class LoanAlerts::NotProgressed < LoanAlerts::Base
  def loans
    super do |loans|
      loans.
        not_progressed.
        last_updated_between(start_date, end_date)
    end
  end

  def self.start_date
    6.months.ago.to_date
  end

  def start_date
    self.class.start_date
  end

  def date_method
    :updated_at
  end
end
