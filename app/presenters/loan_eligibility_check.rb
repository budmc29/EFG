class LoanEligibilityCheck
  include LoanPresenter
  include LoanStateTransition
  include SharedLoanValidations

  attribute :viable_proposition
  attribute :would_you_lend
  attribute :collateral_exhausted
  attribute :not_insolvent
  attribute :lender
  attribute :lending_limit_id, readonly: true
  attribute :sic_code
  attribute :loan_category_id
  attribute :reason_id
  attribute :previous_borrowing
  attribute :private_residence_charge_required
  attribute :personal_guarantee_required
  attribute :amount
  attribute :turnover
  attribute :repayment_duration
  attribute :trading_date
  attribute :loan_scheme
  attribute :loan_source
  attribute :repayment_profile
  attribute :fixed_repayment_amount

  delegate :created_by, :created_by=, :loan_category, :reason, :sic, to: :loan

  validates_presence_of :amount, :lending_limit_id, :repayment_duration,
    :turnover, :trading_date, :sic_code, :loan_category_id, :reason_id
  validates_inclusion_of :viable_proposition, :would_you_lend,
    :collateral_exhausted, :not_insolvent, :previous_borrowing,
    :private_residence_charge_required, :personal_guarantee_required, in: [true, false]
  validates_inclusion_of :loan_scheme, in: [ Loan::EFG_SCHEME ]
  validates_inclusion_of :loan_source, in: [ Loan::SFLG_SOURCE ]

  validate :company_turnover_is_allowed, if: :turnover

  validate do
    errors.add(:amount, :greater_than, count: 0) unless amount && amount.cents > 0
    errors.add(:sic_code, :not_recognised) if sic_code.blank?
  end

  validates_with RepaymentProfileValidator

  before_validation :calculate_repayment_duration

  after_save :save_ineligibility_reasons, unless: :eligible?

  def transition_to
    eligible? ? Loan::Eligible : Loan::Rejected
  end

  def event
    eligible? ? LoanEvent::Accept : LoanEvent::Reject
  end

  def lending_limit_id=(id)
    if id.present?
      lending_limit = loan.lender.lending_limits.active.find(id)
      loan.lending_limit = lending_limit
    else
      loan.lending_limit = nil
    end

    loan.lending_limit_id
  end

  # cache sic code data on loan, as per legacy system
  def sic_code=(code)
    loan.sic_code = loan.sic_desc = loan.sic_eligible = nil

    if code.present? && sic = SicCode.active.find_by_code!(code)
      loan.sic_code = sic.code
      loan.sic_desc = sic.description
      loan.sic_eligible = sic.eligible
    end
  end

  private
    def eligible?
      return @eligible if defined?(@eligible)
      validate_eligibility
      @eligible = ineligibility_reasons.empty?
    end

    def ineligibility_reasons
      # Re-use errors object which will be empty (no validations failures) when
      # we get here.
      errors.messages.values.flatten
    end

    def save_ineligibility_reasons
      loan.ineligibility_reasons.create!(reason: ineligibility_reasons.join("\n"))
    end

    def validate_eligibility
      loan.rules.eligibility_check_validations.each do |validator|
        validator.validate(self)
      end
    end

  def calculate_repayment_duration
    unless repayment_profile == PremiumSchedule::FIXED_AMOUNT_REPAYMENT_PROFILE
      self.repayment_duration ||= 0
      return
    end

    self.repayment_duration = (amount / fixed_repayment_amount).floor
  end
end
