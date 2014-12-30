class LendingLimit < ActiveRecord::Base
  include FormatterConcern

  USAGE_LOAN_STATES = [
    Loan::Guaranteed,
    Loan::LenderDemand,
    Loan::Repaid,
    Loan::Removed,
    Loan::RepaidFromTransfer,
    Loan::AutoRemoved,
    Loan::NotDemanded,
    Loan::Demanded,
    Loan::Settled,
    Loan::Realised,
    Loan::Recovered
  ]

  belongs_to :lender
  belongs_to :modified_by, class_name: 'User'

  has_many :loans

  has_many :loans_using_lending_limit, -> { where("loans.state IN (?)", USAGE_LOAN_STATES) }, class_name: "Loan"

  validates_presence_of :lender_id, strict: true
  validates_presence_of :allocation, :name, :ends_on, :starts_on
  validates_inclusion_of :allocation_type_id, in: [LendingLimitType::Annual, LendingLimitType::Specific].map(&:id)
  validate :ends_on_is_after_starts_on

  attr_accessible :allocation, :allocation_type_id, :name, :ends_on,
    :starts_on, :phase_id

  format :allocation, with: MoneyFormatter.new
  format :ends_on, with: QuickDateFormatter
  format :starts_on, with: QuickDateFormatter

  default_scope order('ends_on DESC, allocation_type_id DESC')

  delegate :euro_conversion_rate, to: :phase

  scope :active, where(active: true)

  def self.current
    today = Date.current

    where("starts_on <= ? AND ends_on >= ?", today, today)
  end

  def allocation_type
    LendingLimitType.find(allocation_type_id)
  end

  def activate!
    update_attribute(:active, true)
  end

  def deactivate!
    update_attribute(:active, false)
  end

  def available?
    ends_on_with_grace_period = ends_on.advance(days: 30)
    active && (starts_on..ends_on_with_grace_period).cover?(Date.current)
  end

  def phase
    Phase.find(phase_id)
  end

  def unavailable?
    !available?
  end

  private
    def ends_on_is_after_starts_on
      return if ends_on.nil? || starts_on.nil?
      errors.add(:ends_on, :must_be_after_starts_on) if ends_on < starts_on
    end
end
