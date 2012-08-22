class StateAidCalculation < ActiveRecord::Base
  include FormatterConcern

  SCHEDULE_TYPE = 'S'.freeze
  RESCHEDULE_TYPE = 'R'.freeze
  NOTIFIED_AID_TYPE = 'N'.freeze
  MAX_INITIAL_DRAW = Money.new(9_999_999_99)

  belongs_to :loan, inverse_of: :state_aid_calculations

  attr_accessible :initial_draw_year, :initial_draw_amount,
    :initial_draw_months, :initial_capital_repayment_holiday,
    :second_draw_amount, :second_draw_months, :third_draw_amount,
    :third_draw_months, :fourth_draw_amount, :fourth_draw_months,
    :loan_id, :premium_cheque_month

  before_validation :set_seq, on: :create

  validates_presence_of :loan_id

  validates_presence_of :initial_draw_months

  validates_inclusion_of :calc_type, in: [ SCHEDULE_TYPE, RESCHEDULE_TYPE, NOTIFIED_AID_TYPE ]

  validates_presence_of :initial_draw_year, unless: :reschedule?

  validates_presence_of :premium_cheque_month, if: :reschedule?

  validate :premium_cheque_month_in_the_future, if: :reschedule?

  validate :initial_draw_amount_is_within_limit

  format :initial_draw_amount, with: MoneyFormatter.new
  format :second_draw_amount, with: MoneyFormatter.new
  format :third_draw_amount, with: MoneyFormatter.new
  format :fourth_draw_amount, with: MoneyFormatter.new

  # We believe these are defined in the relevant legislation?
  GUARANTEE_RATE = 0.75
  RISK_FACTOR = 0.3

  def premium_schedule
    PremiumSchedule.new(self, loan)
  end

  def state_aid_gbp
    (initial_draw_amount * GUARANTEE_RATE * RISK_FACTOR) - premium_schedule.total_premiums
  end

  def state_aid_eur
    euro = state_aid_gbp * 1.1974
    Money.new(euro.cents, 'EUR')
  end

  after_save do |calculation|
    calculation.loan.state_aid = state_aid_eur
    calculation.loan.save
  end

  def reschedule?
    calc_type == RESCHEDULE_TYPE
  end

  private
    def set_seq
      self.seq = (StateAidCalculation.where(loan_id: loan_id).maximum(:seq) || -1) + 1 unless seq
    end

    def initial_draw_amount_is_within_limit
      if initial_draw_amount.blank? || initial_draw_amount < 0 || initial_draw_amount > MAX_INITIAL_DRAW
        errors.add(:initial_draw_amount, :invalid)
      end
    end

    def premium_cheque_month_in_the_future
      cheque_date = Date.parse("01/#{premium_cheque_month}")
      today = Date.today

      unless (cheque_date.year > today.year) || (cheque_date.year == today.year && cheque_date.month > today.month)
        errors.add(:premium_cheque_month, :invalid)
      end
    end
end
