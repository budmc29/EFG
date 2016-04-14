class LoanAlerts::NotClosed < LoanAlerts::Base
  def initialize(lender)
    super

    @guaranteed = LoanAlerts::NotClosedGuaranteed.new(lender)
    @offered = LoanAlerts::NotClosedOffered.new(lender)
  end

  def date_method
    :days_remaining
  end

  def loans
    @loans ||= [@guaranteed, @offered].flat_map(&:loans).sort_by(&date_method)
  end

  def start_date
    @offered.start_date
  end

  def groups
    @groups ||= begin
      @guaranteed.groups.map do |group|
        offered_group = @offered.groups.detect do |g|
          g.priority == group.priority
        end

        CombinedGroup.new(
          priority: group.priority,
          groups: [group, offered_group],
          start_date: group.start_date,
          end_date: group.end_date)
      end
    end
  end
end
