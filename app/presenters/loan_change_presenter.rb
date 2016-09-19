class LoanChangePresenter
  extend  ActiveModel::Callbacks
  extend  ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::MassAssignmentSecurity
  include ActiveModel::Validations

  def self.model_name
    ActiveModel::Name.new(self, nil, 'LoanChange')
  end

  define_model_callbacks :save
  define_model_callbacks :validation

  attr_reader :created_by, :date_of_change, :loan, :current_premium_schedule
  attr_accessible :date_of_change, :initial_draw_amount, :second_draw_amount,
                  :second_draw_months, :third_draw_amount, :third_draw_months,
                  :fourth_draw_amount, :fourth_draw_months,
                  :initial_capital_repayment_holiday

  validates :date_of_change, presence: true
  validate :date_of_change_not_in_the_future, if: :date_of_change
  validate :no_skipped_draws
  validate :draws_have_months

  validates :initial_capital_repayment_holiday,
            numericality: { greater_than_or_equal_to: 0 }, allow_blank: true

  delegate :initial_draw_amount, :initial_draw_amount=, to: :premium_schedule
  delegate :second_draw_amount, :second_draw_amount=, to: :premium_schedule
  delegate :second_draw_months, :second_draw_months=, to: :premium_schedule
  delegate :third_draw_amount, :third_draw_amount=, to: :premium_schedule
  delegate :third_draw_months, :third_draw_months=, to: :premium_schedule
  delegate :fourth_draw_amount, :fourth_draw_amount=, to: :premium_schedule
  delegate :fourth_draw_months, :fourth_draw_months=, to: :premium_schedule
  delegate :initial_capital_repayment_holiday, to: :premium_schedule
  delegate :initial_capital_repayment_holiday=, to: :premium_schedule
  delegate :repayment_profile, to: :premium_schedule
  delegate :repayment_profile=, to: :premium_schedule
  delegate :fixed_repayment_amount, to: :premium_schedule
  delegate :fixed_repayment_amount=, to: :premium_schedule

  def initialize(loan, created_by)
    @loan = loan
    @created_by = created_by
    @current_premium_schedule = loan.premium_schedule || premium_schedule
  end

  def attributes=(attributes)
    sanitize_for_mass_assignment(attributes).each do |k, v|
      public_send("#{k}=", v)
    end
  end

  def current_second_draw
    amount = current_premium_schedule.second_draw_amount || Money.new(0)
    months = current_premium_schedule.second_draw_months

    "#{amount.format} in month #{months}"
  end

  def current_third_draw
    amount = current_premium_schedule.third_draw_amount || Money.new(0)
    months = current_premium_schedule.third_draw_months

    "#{amount.format} in month #{months}"
  end

  def current_fourth_draw
    amount = current_premium_schedule.fourth_draw_amount || Money.new(0)
    months = current_premium_schedule.fourth_draw_months

    "#{amount.format} in month #{months}"
  end

  def current_repayment_duration_at_next_premium
    loan.repayment_duration.total_months - number_of_months_from_start_date_to_next_collection
  end

  def capital_repayment_holiday_change?
    self.class == CapitalRepaymentHolidayLoanChange
  end

  def date_of_change=(value)
    @date_of_change = QuickDateFormatter.parse(value)
  end

  def loan_change
    @loan_change ||= loan.loan_changes.new
  end

  def next_premium_cheque_date
    initial_draw_date.advance(
      months: number_of_months_from_start_date_to_next_collection
    )
  end

  def next_premium_cheque_month
    next_premium_cheque_date.strftime("%m/%Y")
  end

  def persisted?
    false
  end

  def premium_schedule
    @premium_schedule ||= loan.premium_schedules.new.tap do |p|
      p.calc_type = PremiumSchedule::RESCHEDULE_TYPE
      p.repayment_profile = current_premium_schedule.repayment_profile
      p.fixed_repayment_amount = current_premium_schedule.fixed_repayment_amount
      p.initial_draw_year = current_premium_schedule.initial_draw_year ||
                            Date.today.year
    end
  end

  def save
    return false unless valid?

    loan.transaction do
      run_callbacks :save do
        loan_change.created_by = created_by
        loan_change.date_of_change = date_of_change
        loan_change.modified_date = Date.current
        loan_change.save!

        premium_schedule.save!

        loan.last_modified_at = Time.now
        loan.modified_by = created_by
        loan.save!
      end
    end

    true
  end

  def valid?
    run_callbacks :validation do
      super

      # show loan change specific errors first
      return false unless errors.empty?

      premium_schedule.premium_cheque_month = next_premium_cheque_month
      premium_schedule.repayment_duration = repayment_duration_at_next_premium

      if premium_schedule.invalid?
        premium_schedule.errors.each do |key, message|
          errors.add(key, message)
        end
      end
    end

    errors.empty?
  end

  private

    def initial_draw_date
      loan.initial_draw_date
    end

    def number_of_months_from_start_date_to_next_collection
      today = Date.current
      today_months = today.year * 12 + today.month
      initial_draw_date_months = initial_draw_date.year * 12 + initial_draw_date.month
      difference_in_months = today_months - initial_draw_date_months

      months = (difference_in_months.to_f / 3).ceil * 3
      months += 3 if today.beginning_of_month == initial_draw_date.advance(months: months).beginning_of_month
      months
    end

    def repayment_duration_at_next_premium
      current_repayment_duration_at_next_premium
    end

    def date_of_change_not_in_the_future
      if date_of_change > Date.current
        errors.add(:date_of_change, :cannot_be_in_the_future)
      end
    end

    def draws_have_months
      errors.add(:second_draw_months, :required) if second_draw_amount && second_draw_months.blank?
      errors.add(:third_draw_months, :required) if third_draw_amount && third_draw_months.blank?
      errors.add(:fourth_draw_months, :required) if fourth_draw_amount && fourth_draw_months.blank?
    end

    def no_skipped_draws
      if (third_draw_amount or fourth_draw_amount) and not second_draw_amount
        errors.add(:second_draw_amount, :no_skipping)
      end
      errors.add(:third_draw_amount, :no_skipping) if fourth_draw_amount and not third_draw_amount
    end
end
