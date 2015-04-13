class LoanRealisation < ActiveRecord::Base
  include FormatterConcern

  belongs_to :realisation_statement
  belongs_to :realised_loan, class_name: 'Loan'
  belongs_to :created_by, class_name: 'User'

  validates_presence_of :created_by, strict: true
  validates_presence_of :realisation_statement_id
  validates_presence_of :realised_amount, strict: true
  validates_presence_of :realised_loan_id, strict: true
  validates_presence_of :realised_on, strict: true

  attr_accessible :realised_loan, :created_by, :realised_amount

  scope :pre_claim_limit, -> { where(post_claim_limit: false) }
  scope :post_claim_limit, -> { where(post_claim_limit: true) }

  format :realised_amount, with: MoneyFormatter.new

  def scheme
    if loan_source == Loan::LEGACY_SFLG_SOURCE
      'Legacy'
    elsif loan_scheme == Loan::SFLG_SCHEME
      'New'
    else
      'EFG'
    end
  end
end
