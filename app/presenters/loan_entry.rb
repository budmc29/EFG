class LoanEntry
  include LoanPresenter
  include LoanStateTransition
  include SharedLoanValidations

  transition from: [Loan::Eligible, Loan::Incomplete], to: Loan::Completed, event: LoanEvent::Complete

  attribute :lender, read_only: true
  attribute :state_aid_threshold, read_only: true

  attribute :viable_proposition
  attribute :would_you_lend
  attribute :collateral_exhausted
  attribute :not_insolvent
  attribute :sic_code
  attribute :loan_category_id
  attribute :loan_sub_category_id
  attribute :reason_id
  attribute :previous_borrowing
  attribute :private_residence_charge_required
  attribute :personal_guarantee_required
  attribute :lender_reference
  attribute :amount
  attribute :turnover
  attribute :trading_date
  attribute :lending_limit_id
  attribute :repayment_duration
  attribute :declaration_signed
  attribute :business_name
  attribute :trading_name
  attribute :legal_form_id
  attribute :company_registration
  attribute :postcode
  attribute :sortcode
  attribute :repayment_frequency_id
  attribute :generic1
  attribute :generic2
  attribute :generic3
  attribute :generic4
  attribute :generic5
  attribute :interest_rate_type_id
  attribute :interest_rate
  attribute :fees
  attribute :state_aid_is_valid
  attribute :state_aid
  attribute :loan_security_types
  attribute :security_proportion
  attribute :original_overdraft_proportion
  attribute :refinance_security_proportion
  attribute :current_refinanced_amount
  attribute :final_refinanced_amount
  attribute :overdraft_limit
  attribute :overdraft_maintained
  attribute :invoice_discount_limit
  attribute :invoice_prepayment_coverage_percentage
  attribute :invoice_prepayment_topup_percentage
  attribute :sub_lender
  attribute :repayment_profile
  attribute :fixed_repayment_amount

  attribute :legal_form, read_only: true

  delegate :calculate_state_aid, :reason, :sic, to: :loan
  delegate :sub_lender_names, to: :lender

  validates_presence_of :business_name, :fees, :interest_rate,
                        :interest_rate_type_id, :legal_form_id,
                        :repayment_frequency_id
  validates_presence_of :state_aid

  validates_presence_of :company_registration, if: ->(loan_entry) do
    loan_entry.legal_form &&
      loan_entry.legal_form.requires_company_registration
  end

  validate :postcode_allowed
  validate :state_aid_calculated
  validate :state_aid_within_sic_threshold, if: :state_aid
  validate :repayment_frequency_allowed
  validate :company_turnover_is_allowed, if: :turnover
  validates_acceptance_of :state_aid_is_valid, allow_nil: false, accept: true
  validates_inclusion_of :sub_lender, in: :sub_lender_names, if: -> { sub_lender_names.any? }

  validate do
    errors.add(:declaration_signed, :accepted) unless self.declaration_signed
  end

  validates_with RepaymentProfileValidator

  validate :validate_eligibility
  validate :category_validations

  before_validation :calculate_repayment_duration

  def premium_schedule_required_for_state_aid_calculation?
    loan.rules.premium_schedule_required_for_state_aid_calculation?
  end

  def save_as_incomplete
    run_callbacks :validation do
      loan.state = Loan::Incomplete
      yield self if block_given?
      loan.save(validate: false)
    end
  end

  def complete?
    loan.state == Loan::Completed
  end

  def total_prepayment
    (invoice_prepayment_coverage_percentage || 0) + (invoice_prepayment_topup_percentage || 0)
  end

  private

  def category_validations
    validators = LoanCategoryValidators.for_category(loan_category_id)
    validators.each do |validator|
      validator.validate(self)
    end
  end

  def postcode_allowed
    errors.add(:postcode, :invalid) unless postcode.full?
  end

  def state_aid_calculated
    if loan.repayment_duration_changed? || loan.amount_changed?
      errors.add(:state_aid, :recalculate)
    end
  end

  def validate_eligibility
    loan.rules.loan_entry_validations.each do |validator|
      validator.validate(self)
    end
  end

  def state_aid_within_sic_threshold
    if state_aid > state_aid_threshold
      errors.add(:state_aid, :exceeds_sic_threshold, threshold: state_aid_threshold.format(no_cents: true))
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
