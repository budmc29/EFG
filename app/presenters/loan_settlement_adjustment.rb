class LoanSettlementAdjustment
  include ActiveModel::Model

  attr_accessor :created_by
  attr_reader :amount, :date, :notes

  validates :amount, presence: true
  validates :created_by, presence: true
  validates :date, presence: true

  validate :positive_amount

  def initialize(loan, attributes = {})
    @loan = loan
    self.amount = attributes[:amount]
    self.date = attributes[:date]
    self.notes = attributes[:notes]
  end

  def save
    return false unless valid?

    loan.settlement_adjustments.create! do |s|
      s.amount = amount
      s.date = date
      s.notes = notes
      s.created_by = created_by
    end
  end

  private

  attr_reader :loan
  attr_writer :notes

  def amount=(value)
    @amount = value.present? ? Money.parse(value) : nil
  end

  def date=(value)
    @date = QuickDateFormatter.parse(value)
  end

  def positive_amount
    unless amount && amount.cents > 0
      errors.add(:amount, :greater_than, count: 0)
    end
  end
end
