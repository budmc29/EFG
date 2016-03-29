# "Offered loans have 6 months to progress from offered to guaranteed state
# – if not they progress to auto cancelled""
class LoanAlerts::NotDrawn < LoanAlerts::Base
  def loans
    super do |loans|
      loans.
        offered.
        facility_letter_date_between(alert_range.first, alert_range.last)
    end
  end

  # Lenders have an extra 10 working days of grace to record the initial draw.
  def self.start_date
    10.weekdays_ago(6.months.ago).to_date
  end

  def self.date_method
    :facility_letter_date
  end
end
