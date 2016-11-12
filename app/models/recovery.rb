class Recovery < ActiveRecord::Base
  include FormatterConcern
  include Sequenceable

  belongs_to :loan
  belongs_to :created_by, class_name: 'User'
  belongs_to :realisation_statement

  scope :realised, -> { where(realise_flag: true) }

  validates_presence_of :loan, strict: true
  validates_presence_of :created_by, strict: true
  validates_presence_of :recovered_on

  validate :validate_scheme_fields
  validate :recovered_on_is_not_in_the_future, if: :recovered_on
  validate do
    if loan && recovered_on && recovered_on < loan.settled_on
      errors.add(:recovered_on, 'must not be before the loan was settled')
    end
  end

  format :recovered_on, with: QuickDateFormatter
  format :outstanding_prior_non_efg_debt, with: MoneyFormatter.new
  format :outstanding_subsequent_non_efg_debt, with: MoneyFormatter.new
  format :non_linked_security_proceeds, with: MoneyFormatter.new
  format :linked_security_proceeds, with: MoneyFormatter.new
  format :realisations_attributable, with: MoneyFormatter.new
  format :amount_due_to_dti, with: MoneyFormatter.new
  format :total_proceeds_recovered, with: MoneyFormatter.new
  format :total_liabilities_after_demand, with: MoneyFormatter.new
  format :total_liabilities_behind, with: MoneyFormatter.new
  format :additional_break_costs, with: MoneyFormatter.new
  format :additional_interest_accrued, with: MoneyFormatter.new
  format :realisations_due_to_gov, with: MoneyFormatter.new

  attr_accessible :recovered_on, :outstanding_prior_non_efg_debt,
                  :outstanding_subsequent_non_efg_debt,
                  :non_linked_security_proceeds, :linked_security_proceeds,
                  :total_liabilities_behind, :total_liabilities_after_demand,
                  :additional_interest_accrued, :additional_break_costs

  attr_accessor :amount_due_to_sec_state

  delegate :dti_amount_claimed, :dti_interest, :dti_demand_outstanding,
           to: :loan

  def loan_guarantee_rate
    loan.guarantee_rate / 100
  end

  def calculate
    self.realisations_attributable = calculator.realisations_attributable
    self.amount_due_to_dti = calculator.amount_due_to_dti
    self.amount_due_to_sec_state = calculator.amount_due_to_sec_state

    if amount_due_to_dti > amount_yet_to_be_recovered
      errors.add(:base, :recovery_too_high)
    end

    amount_due_to_dti
  end

  def amount_yet_to_be_recovered
    loan.dti_amount_claimed - loan.cumulative_recoveries_amount
  end

  def calculator
    @calculator ||= {
      legacy: LegacySflgRecoveryCalculator,
      new: SflgRecoveryCalculator,
      efg: EfgRecoveryCalculator,
    }.fetch(loan.scheme).new(self)
  end

  def save_and_update_loan
    transaction do
      save!
      update_loan!
      log_loan_state_change!
    end

    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  def scheme
    if loan_source == Loan::LEGACY_SFLG_SOURCE
      'Legacy'
    elsif loan_scheme == Loan::SFLG_SCHEME
      'New'
    else
      'EFG'
    end
  end

  def set_total_proceeds_recovered
    if loan.legacy_loan?
      self.total_proceeds_recovered = loan.dti_amount_claimed * (loan.guarantee_rate / 100)
    else
      interest = loan.dti_interest || Money.new(0)
      outstanding = loan.dti_demand_outstanding || Money.new(0)

      self.total_proceeds_recovered = interest + outstanding
    end
  end

  private
    def update_loan!
      loan.modified_by = created_by
      loan.recovery_on = recovered_on
      loan.state = Loan::Recovered
      loan.save!
    end

    def log_loan_state_change!
      LoanStateChange.log(loan, LoanEvent::RecoveryMade, created_by)
    end

    def recovered_on_is_not_in_the_future
      if recovered_on > Date.current
        errors.add(:recovered_on, :cannot_be_in_the_future)
      end
    end

    def validate_scheme_fields
      if loan.efg_loan?
        required = [
          :linked_security_proceeds,
          :outstanding_prior_non_efg_debt,
          :non_linked_security_proceeds,
        ]

        # only newer recoveries require this field
        # older, existing recoveries will have no value for this field
        # so should still be valid
        if new_record?
          required << :outstanding_subsequent_non_efg_debt
        end
      else
        required = [
          :total_liabilities_behind,
          :total_liabilities_after_demand,
        ]
      end

      required.each do |attribute|
        errors.add(attribute, :blank) if self[attribute].blank?
      end
    end
end
