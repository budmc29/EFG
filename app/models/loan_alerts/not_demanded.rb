# "All new scheme and legacy loans that are in a state of “Lender Demand”
# have a 12 month time frame to be progressed to “Demanded”
# – if they do not, they will become “Auto Removed”."
# "EFG loans however, should not be subjected to this alert
class LoanAlerts::NotDemanded < LoanAlerts::Base
  def loans
    super do |loans|
      loans.
        with_scheme('non_efg').
        lender_demanded.
        borrower_demanded_date_between(start_date, end_date)
    end
  end

  def self.start_date
    365.days.ago.to_date
  end

  def start_date
    self.class.start_date
  end

  def date_method
    :borrower_demanded_on
  end
end
