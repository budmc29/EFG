class ClaimLimitCalculator

  ClaimLimitStates = [
    Loan::Guaranteed,
    Loan::LenderDemand,
    Loan::Repaid,
    Loan::RepaidFromTransfer,
    Loan::NotDemanded,
    Loan::Demanded,
    Loan::Settled,
    Loan::Realised,
    Loan::Recovered,
    Loan::AutoRemoved,
    Loan::Removed,
  ].freeze

  SettledStates = [
    Loan::Settled,
    Loan::Realised,
    Loan::Recovered,
  ].freeze

  ChangeTypesWithDraws = [
    ChangeType::CapitalRepaymentHoliday,
    ChangeType::DecreaseTerm,
    ChangeType::ExtendTerm,
    ChangeType::LumpSumRepayment,
    ChangeType::RecordAgreedDraw,
    ChangeType::ReprofileDraws,
    ChangeType::RepaymentFrequency
  ].freeze

  EXCLUDED_STATUS_AMENDMENTS = [
    LoanStatusAmendment::ELIGIBILITY,
    LoanStatusAmendment::ADMINISTRATIVE,
  ].freeze

  attr_reader :lender

  def initialize(lender)
    @lender = lender
  end

  def self.all_with_amount(lenders)
    lenders.each_with_object([]) do |lender, memo|
      Phase.all.each do |phase|
        calculator = phase.rules.claim_limit_calculator.new(lender)
        memo << calculator unless calculator.total_amount.zero?
      end
    end
  end

  def amount_remaining
    remainder = total_amount + pre_claim_realisations_amount - settled_amount
    remainder < 0 ? Money.new(0) : remainder
  end

  def cumulative_drawn_amount
    @cumulative_drawn_amount ||= begin
      amount = cumulative_drawn_amount_relation.sum(:amount_drawn)
      Money.new(amount)
    end
  end

  def percentage_remaining
    return 0 if total_amount.zero? || amount_remaining.zero?

    (amount_remaining / total_amount * 100).round
  end

  def phase
    raise NotImplementedError, 'Implement in sub-class'
  end

  def pre_claim_realisations_amount
    @pre_claim_realisations_amount ||= begin
      pre_claim_realisations_amount = Loan
        .joins(:loan_realisations)
        .joins(:lending_limit)
        .where(lender_id: lender.id)
        .where(loan_scheme: Loan::EFG_SCHEME)
        .where(state: SettledStates)
        .where(lending_limits: { phase_id: phase.id })
        .where(loan_realisations: { post_claim_limit: false })
        .sum(:realised_amount)

      realisation_adjustments_amount = pre_claim_limit_realisation_adjustments.sum(:amount)

      Money.new(pre_claim_realisations_amount) - Money.new(realisation_adjustments_amount)
    end
  end

  def settled_amount
    @settled_amount ||= begin
      loans = Loan.
        select("
          loans.id,
          IFNULL(loans.settled_amount, 0) as unadjusted_settled_amount
        ").
        joins(:lending_limit).
        where(lender_id: lender.id).
        where(loan_scheme: Loan::EFG_SCHEME).
        where(state: SettledStates).
        where(lending_limits: { phase_id: phase.id }).
        to_a

      adjustments_amount = SettlementAdjustment.
        where(loan: loans.map(&:id)).
        sum(:amount)

      Money.new(loans.sum(&:unadjusted_settled_amount) + adjustments_amount)
    end
  end

  def total_amount
    raise NotImplementedError, 'Implement in sub-class'
  end

  private

  def cumulative_drawn_amount_relation
    Loan
      .joins(:loan_modifications)
      .joins(:lending_limit)
      .where(lender_id: lender.id)
      .where(loan_scheme: Loan::EFG_SCHEME)
      .where(state: ClaimLimitStates)
      .where("loan_modifications.type = 'InitialDrawChange' OR
              loan_modifications.change_type_id IN (?)",
              ChangeTypesWithDraws.collect(&:id))
      .where(lending_limits: { phase_id: phase.id })
      .where("status_amendment_type IS NULL OR
              status_amendment_type NOT IN (?)", EXCLUDED_STATUS_AMENDMENTS)
  end

  def pre_claim_limit_realisation_adjustments
    RealisationAdjustment
      .joins(loan: :lending_limit)
      .where(post_claim_limit: false)
      .where(loans: { lender_id: lender.id })
      .where(lending_limits: { phase_id: phase.id })
  end
end
