class LenderLendingLimit
  include ActiveModel::Model
  include ActiveModel::MassAssignmentSecurity

  attr_reader :allocation, :lender

  attr_accessor :selected, :active

  validates :allocation, presence: true

  delegate :id, :name, :to_key, to: :lender

  def initialize(lender)
    @lender = lender
    @active = true
  end

  def selected?
    !!selected
  end

  def allocation=(value)
    if value.present?
      @allocation = Money.parse(value)
    else
      @allocation = nil
    end
  end
end
