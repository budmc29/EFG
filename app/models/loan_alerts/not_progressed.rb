# "All schemes, any loan that has remained at the state of
# “eligible” / “incomplete” or “complete”
# – for a period of 6 months from entering those states – should be ‘auto cancelled’"
class LoanAlerts::NotProgressed < LoanAlerts::Base
  def loans
    super do |loans|
      loans.
        not_progressed.
        last_updated_between(alert_range.first, alert_range.last)
    end
  end

  def self.start_date
    6.months.ago.to_date
  end

  def self.date_method
    :updated_at
  end
end
