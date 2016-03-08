class RealisationAdjustment < Adjustment
  include FormatterConcern

  belongs_to :loan
  belongs_to :created_by, class_name: 'User'

  scope :pre_claim_limit, -> { where(post_claim_limit: false) }
  scope :post_claim_limit, -> { where(post_claim_limit: true) }

  format :amount, with: MoneyFormatter.new
  format :date, with: QuickDateFormatter

  validates_presence_of :amount, strict: true
  validates_presence_of :created_by, strict: true
  validates_presence_of :date, strict: true
  validates_presence_of :loan, strict: true
end
