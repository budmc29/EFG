# "Offered loans have 6 months to progress from offered to guaranteed state
# – if not they progress to auto cancelled""
class LoanAlerts::NotDrawn < LoanAlerts::Base
  def loans
    super do |loans|
      loans.
        offered.
        facility_letter_date_between(start_date, end_date)
    end
  end

  # Lenders have an extra 10 working days of grace to record the initial draw.
  def self.start_date
    10.weekdays_ago(6.months.ago).to_date
  end

  def start_date
    self.class.start_date
  end

  def date_method
    :facility_letter_date
  end

  def groups
    @groups ||= begin
      [
        LoanAlertGroup.new(
          loans: loans,
          priority: :overdue,
          method_name: date_method,
          start_date: start_date,
          end_date: 9.weekdays_from(start_date),
        ),
        LoanAlertGroup.new(
          loans: loans,
          priority: :high,
          method_name: date_method,
          start_date: 10.weekdays_from(start_date),
          end_date: 19.weekdays_from(start_date),
        ),
        LoanAlertGroup.new(
          loans: loans,
          priority: :medium,
          method_name: date_method,
          start_date: 20.weekdays_from(start_date),
          end_date: 39.weekdays_from(start_date),
        ),
        LoanAlertGroup.new(
          loans: loans,
          priority: :low,
          method_name: date_method,
          start_date: 40.weekdays_from(start_date),
          end_date: 59.weekdays_from(start_date),
        ),
      ]
    end
  end
end
