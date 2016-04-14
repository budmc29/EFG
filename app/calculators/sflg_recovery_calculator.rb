class SflgRecoveryCalculator
  def initialize(recovery)
    @recovery = recovery

    recovery.additional_break_costs ||= Money.new(0)
    recovery.additional_interest_accrued ||= Money.new(0)
  end

  def realisations_attributable
    Money.new(0)
  end

  def amount_due_to_sec_state
    recovery.total_liabilities_after_demand *
      recovery.loan_guarantee_rate * magic_number
  end

  def amount_due_to_dti
    amount_due_to_sec_state + recovery.additional_break_costs +
      recovery.additional_interest_accrued
  end

  private

  attr_reader :recovery

  def interest_plus_outstanding
    recovery.dti_interest + recovery.dti_demand_outstanding
  end

  def magic_number
    interest_plus_outstanding / (interest_plus_outstanding +
                                 recovery.total_liabilities_behind)
  end
end
