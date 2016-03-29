class LoanAlerts::NotClosed < LoanAlerts::Base
  def initialize(lender, priority = nil)
    super

    @guaranteed = LoanAlerts::NotClosedGuaranteed.new(lender, priority)
    @offered = LoanAlerts::NotClosedOffered.new(lender, priority)
  end

  def self.date_method
    :days_remaining
  end

  def loans
    @loans ||= [@guaranteed, @offered].flat_map(&:loans).sort_by(&date_method)
  end

  def start_date
    @offered.start_date
  end
end
