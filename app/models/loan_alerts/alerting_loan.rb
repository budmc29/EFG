class LoanAlerts::AlertingLoan < SimpleDelegator
  def initialize(loan, start_date, date_method)
    @start_date = start_date
    @date_method = date_method
    super(loan)
  end

  def date
    days_remaining.weekdays_from(start_date)
  end

  def days_remaining
    start_date.weekdays_until(send(date_method))
  end

  private

  attr_reader :start_date, :date_method
end
