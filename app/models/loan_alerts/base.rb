# Loan Alert sub-classes & behaviour from 'CfEL Response to Initial Questions.docx'.
#
# Note: alert range is 60 week days (no support for public holidays)
class LoanAlerts::Base
  include Enumerable

  def initialize(lender)
    @lender = lender
  end

  def loans
    @loans ||= begin
      scope = lender.loans.order(date_method)
      scope = yield scope if block_given?
      scope.map do |loan|
        LoanAlerts::AlertingLoan.new(loan, start_date, date_method)
      end
    end
  end

  def each(&block)
    loans.each(&block)
  end

  def group(priority = nil)
    unless priority
      return CombinedGroup.new(
        priority: priority,
        groups: groups,
        start_date: start_date,
        end_date: end_date)
    end

    groups.detect { |g| g.priority == priority.to_sym }
  end

  def start_date
    raise NotImplementedError, "subclasses must implement .start_date"
  end

  def end_date
    60.weekdays_from(start_date).to_date
  end

  def date_method
    raise NotImplementedError, "subclasses must implement .date_method"
  end

  def groups
    @groups ||= begin
      [
        LoanAlertGroup.new(
          loans: loans,
          priority: :high,
          method_name: date_method,
          start_date: start_date,
          end_date: 10.weekdays_from(start_date),
        ),
        LoanAlertGroup.new(
          loans: loans,
          priority: :medium,
          method_name: date_method,
          start_date: 11.weekdays_from(start_date),
          end_date: 30.weekdays_from(start_date),
        ),
        LoanAlertGroup.new(
          loans: loans,
          priority: :low,
          method_name: date_method,
          start_date: 31.weekdays_from(start_date),
          end_date: 60.weekdays_from(start_date),
        ),
      ]
    end
  end

  private

  attr_reader :lender

  class LoanAlertGroup
    include Enumerable

    def initialize(opts = {})
      @loans = opts.fetch(:loans)
      @priority = opts.fetch(:priority)
      @method_name = opts.fetch(:method_name)
      @start_date = opts.fetch(:start_date).last_weekday
      @end_date = opts.fetch(:end_date)
    end

    def name
      priority.to_s.titleize
    end

    def each(&block)
      grouped_loans.each(&block)
    end

    def loans_with_days_remaining(day_number)
      grouped_loans.select { |l| l.days_remaining == day_number }
    end

    def date_range
      (start_date..end_date)
    end

    def grouped_loans
      @grouped_loans ||= loans.select do |loan|
        loan.date.between?(start_date, end_date)
      end
    end

    attr_reader :priority, :method_name, :start_date, :end_date

    private

    attr_reader :loans
  end

  class CombinedGroup
    include Enumerable

    def initialize(opts = {})
      @priority = opts.fetch(:priority)
      @groups = opts.fetch(:groups)
      @start_date = opts.fetch(:start_date)
      @end_date = opts.fetch(:end_date)
    end

    def name
      priority.to_s.titleize
    end

    def each(&block)
      grouped_loans.each(&block)
    end

    def loans_with_days_remaining(day_number)
      grouped_loans.select { |l| l.days_remaining == day_number }
    end

    def date_range
      (start_date..end_date)
    end

    def grouped_loans
      @grouped_loans ||= groups.reduce([]) do |memo, group|
        memo + group.grouped_loans
      end
    end

    attr_reader :priority

    private

    attr_reader :groups, :start_date, :end_date
  end
end
