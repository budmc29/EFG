class PremiumSchedule < ActiveRecord::Base
  include FormatterConcern
  include Sequenceable

  SCHEDULE_TYPE = 'S'.freeze
  RESCHEDULE_TYPE = 'R'.freeze
  NOTIFIED_AID_TYPE = 'N'.freeze

  FIXED_TERM_REPAYMENT_PROFILE = "fixed_term".freeze
  FIXED_AMOUNT_REPAYMENT_PROFILE = "fixed_amount".freeze
  REPAYMENT_PROFILES = [
    FIXED_TERM_REPAYMENT_PROFILE,
    FIXED_AMOUNT_REPAYMENT_PROFILE
  ].freeze

  MAX_INITIAL_DRAW = Money.new(9_999_999_99)

  belongs_to :loan, inverse_of: :premium_schedules

  attr_accessible :initial_draw_year, :initial_draw_amount,
    :initial_capital_repayment_holiday,
    :second_draw_amount, :second_draw_months, :third_draw_amount,
    :third_draw_months, :fourth_draw_amount, :fourth_draw_months,
    :loan_id, :premium_cheque_month, :repayment_profile,
    :fixed_repayment_amount

  validates_presence_of :loan_id, strict: true
  validates_presence_of :repayment_duration
  validates_inclusion_of :calc_type, in: [ SCHEDULE_TYPE, RESCHEDULE_TYPE, NOTIFIED_AID_TYPE ]
  validates_presence_of :initial_draw_year, unless: :reschedule?
  validates_format_of :premium_cheque_month, with: /\A\d{2}\/\d{4}\z/, if: :reschedule?, message: :invalid_format

  validates_with RepaymentProfileValidator

  %w(second_draw_months third_draw_months fourth_draw_months).each do |attr|
    validates_inclusion_of attr, in: 0..120, allow_blank: true, message: :invalid
  end

  validate :premium_cheque_month_in_the_future, if: :reschedule?
  validate :initial_draw_amount_is_within_limit
  validate :total_draw_amount_less_than_or_equal_to_loan_amount
  validate :validate_capital_repayment_holiday
  validate :additional_draws_have_amount_and_month
  validate :initial_draw_year_is_within_five_years

  before_validation :calculate_repayment_duration

  format :initial_draw_amount, with: MoneyFormatter.new
  format :second_draw_amount, with: MoneyFormatter.new
  format :third_draw_amount, with: MoneyFormatter.new
  format :fourth_draw_amount, with: MoneyFormatter.new
  format :fixed_repayment_amount, with: MoneyFormatter.new

  def self.from_loan(loan)
    loan.premium_schedules.build.tap do |ps|
      ps.initial_draw_amount ||= loan.amount.dup
      ps.repayment_profile ||= loan.repayment_profile
      ps.fixed_repayment_amount ||= loan.fixed_repayment_amount
      ps.repayment_duration = loan.repayment_duration.total_months
    end
  end

  def reschedule?
    calc_type == RESCHEDULE_TYPE
  end

  def has_drawdowns?
    drawdowns.length > 1
  end

  def drawdowns
    [TrancheDrawdown.new(initial_draw_amount, 0)].tap do |drawdowns|
      if second_draw_amount.present? && second_draw_amount.nonzero? && second_draw_months.present?
        drawdowns << TrancheDrawdown.new(second_draw_amount, second_draw_months)
      end

      if third_draw_amount.present? && third_draw_amount.nonzero? && third_draw_months.present?
        drawdowns << TrancheDrawdown.new(third_draw_amount, third_draw_months)
      end

      if fourth_draw_amount.present? && fourth_draw_amount.nonzero? && fourth_draw_months.present?
        drawdowns << TrancheDrawdown.new(fourth_draw_amount, fourth_draw_months)
      end
    end
  end

  def premiums
    @premiums ||= loan_quarters.map do |loan_quarter|
      outstanding_loan_value_at_quarter =
        outstanding_value_class.new(
          drawdowns: drawdowns,
          quarter: loan_quarter,
          repayment_frequency: repayment_frequency,
          repayment_duration: repayment_duration,
          repayment_holiday: initial_capital_repayment_holiday,
          fixed_repayment_amount: fixed_repayment_amount,
        ).amount

      Money.new(
        (outstanding_loan_value_at_quarter.to_d * 100) *
        premium_rate_per_quarter
      )
    end
  end

  def save_and_update_loan_state_aid
    transaction do
      save.tap { |saved|
        if saved
          loan.calculate_state_aid
          loan.save!
        end
      }
    end
  end

  def total_premiums
    premiums.reduce(Money.new(0), :+)
  end

  def initial_draw_date
    loan.initial_draw_change.try :date_of_change
  end

  def subsequent_premiums
    @subsequent_premiums ||= reschedule? ? premiums : premiums[1..-1]
  end

  def number_of_subsequent_payments
    subsequent_premiums.count {|amount| amount > 0 }
  end

  def total_subsequent_premiums
    subsequent_premiums.empty? ? Money.new(0) : subsequent_premiums.sum
  end

  # This returns a string because its not really a valid date and it doesn't
  # have a day. We could just pick an arbitary day, but then it might be
  # tempting to (incorrectly) format it in the view with the day shown.
  def second_premium_collection_month
    return unless initial_draw_date
    initial_draw_date.advance(months: 3).strftime('%m/%Y')
  end

  def initial_premium_cheque
    reschedule? ? Money.new(0) : premiums.first
  end

  def initial_capital_repayment_holiday
    # Force nil => 0
    super.to_i
  end

  def premium_rate_per_quarter
    loan.premium_rate / 100 / 4
  end

  def repayment_frequency
    if legacy_premium_calculation
      RepaymentFrequency::Monthly
    else
      loan.repayment_frequency
    end
  end

  private

  def fixed_amount_repayment_profile?
    repayment_profile == FIXED_AMOUNT_REPAYMENT_PROFILE
  end

  def outstanding_value_class
    if fixed_repayment_amount
      FixedRepaymentAmountOutstandingLoanValue
    else
      FixedRepaymentDurationOutstandingLoanValue
    end
  end

    def initial_draw_amount_is_within_limit
      if initial_draw_amount.blank?
        errors.add(:initial_draw_amount, :required)
      elsif initial_draw_amount <= 0
        errors.add(:initial_draw_amount, :must_be_positive)
      elsif initial_draw_amount > MAX_INITIAL_DRAW
        errors.add(:initial_draw_amount, :invalid)
      end
    end

    def premium_cheque_month_in_the_future
      begin
        date = Date.parse("01/#{premium_cheque_month}")
      rescue ArgumentError
        errors.add(:premium_cheque_month, :invalid_format)
        return
      end

      errors.add(:premium_cheque_month, :invalid) unless date > Date.current.end_of_month
    end

    def total_draw_amount
      drawdowns.map(&:amount).sum
    end

    def total_draw_amount_less_than_or_equal_to_loan_amount
      if loan.amount < total_draw_amount
        errors.add(:initial_draw_amount, :not_less_than_or_equal_to_loan_amount, loan_amount: loan.amount.format)
        errors.add(:second_draw_amount, :not_less_than_or_equal_to_loan_amount, loan_amount: loan.amount.format)
        errors.add(:third_draw_amount, :not_less_than_or_equal_to_loan_amount, loan_amount: loan.amount.format)
        errors.add(:fourth_draw_amount, :not_less_than_or_equal_to_loan_amount, loan_amount: loan.amount.format)
      end
    end

    # The legacy system rounded down which excludes the last quarter from the
    # premium schedule. This is a bug as the last quarter should be in the
    # schedule, but we are replicating it for now for data consistency.
    def number_of_loan_quarters
      @number_of_loan_quarters ||= begin
        if legacy_premium_calculation
          quarters = repayment_duration / 3
          quarters = 1 if quarters.zero?
          quarters
        else
          total_months = repayment_duration.to_f
          if fixed_amount_repayment_profile?
            total_months += initial_capital_repayment_holiday.to_f
          end
          (total_months / 3).ceil
        end
      end
    end

    def loan_quarters
      (0...number_of_loan_quarters).map { |n| LoanQuarter.new(n) }
    end

    def validate_capital_repayment_holiday
      if initial_capital_repayment_holiday < 0
        errors.add(:initial_capital_repayment_holiday, :must_be_gt_zero)
      end

      return unless repayment_duration.present?

      if initial_capital_repayment_holiday >= repayment_duration
        errors.add(:initial_capital_repayment_holiday, :must_be_lt_loan_duration)
      end
    end

    def additional_draws_have_amount_and_month
      %i(second_draw third_draw fourth_draw).each do |draw_number|
        amount_attr = "#{draw_number}_amount"
        month_attr = "#{draw_number}_months"
        draw_amount = public_send(amount_attr)
        draw_month = public_send(month_attr)

        if draw_amount.present? && draw_month.blank?
          errors.add(month_attr, :blank)
        elsif draw_month.present? && draw_amount.blank?
          errors.add(amount_attr, :blank)
        end
      end
    end

    def initial_draw_year_is_within_five_years
      if initial_draw_year &&
          initial_draw_year > Date.today.advance(years: 5).year
        errors.add(:initial_draw_year, :too_far_in_the_future)
      end
    end

  def calculate_repayment_duration
    return unless repayment_profile == FIXED_AMOUNT_REPAYMENT_PROFILE

    self.repayment_duration = (total_draw_amount / fixed_repayment_amount).floor
  end
end
