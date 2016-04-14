# Takes an array of loans and groups them by priority for use in a dashboard
# loan alert graph
#
#   high priority: loans within 10 week days of the start date
#   medium priority: loans between 11 and 30 week days of the start date
#   low priority: loans between 31 and 60 week days of the start date
#
module LoanAlerts
  class PriorityGrouping
    def initialize(alert)
      @alert       = alert
      @loans       = alert.loans
      @start_date  = alert.start_date.to_date
      @end_date    = alert.end_date.to_date
      @date_method = alert.date_method
      @day_count   = 0
    end

    def alerts_grouped_by_priority
      @alert.groups.map.with_index do |group, index|
        loans = alert_groups[index]
        Group.new(loans, group.priority, total_loan_count)
      end
    end

    def total_loan_count
      alert_groups.map do |group|
        group.map(&:count).max
      end.max
    end

    private

    def alert_groups
      @alert_groups ||= @alert.groups.map do |group|
        loans_by_day(group)
      end
    end

    def loans_by_day(group)
      group.date_range.each_with_object({}) do |date, memo|
        next unless date.weekday? # ignore weekends

        loans = group.loans_with_days_remaining(@day_count)
        memo[date] = loans
        @day_count += 1
      end.values
    end
  end
end
