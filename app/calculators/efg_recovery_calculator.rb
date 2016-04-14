class EfgRecoveryCalculator
  def initialize(recovery)
    @recovery = recovery
  end

  def realisations_attributable
    recovery.linked_security_proceeds +
      non_linked_security_proceeds_efg_debt_amount
  end

  def amount_due_to_dti
    non_linked_security_proceeds_efg_debt_amount *
      recovery.loan_guarantee_rate
  end

  def amount_due_to_sec_state
    Money.new(0)
  end

  private

  attr_reader :recovery

  def value_of_efg_debt
    recovery.dti_demand_outstanding
  end

  def total_debt
    value_of_efg_debt +
      recovery.outstanding_prior_non_efg_debt +
      recovery.outstanding_subsequent_non_efg_debt
  end

  def total_realisations
    recovery.linked_security_proceeds +
      recovery.non_linked_security_proceeds
  end

  def remaining_efg_debt
    [
      value_of_efg_debt - recovery.linked_security_proceeds,
      Money.new(0),
    ].max
  end

  def remaining_non_linked_security_proceeds
    [
      recovery.non_linked_security_proceeds -
        recovery.outstanding_prior_non_efg_debt,
      Money.new(0),
    ].max
  end

  def non_linked_security_proceeds_efg_debt_amount
    remaining_non_linked_security_proceeds *
      distrubution_of_remaining_securities
  end

  def distrubution_of_remaining_securities
    remaining_efg_debt / (
      remaining_efg_debt + recovery.outstanding_subsequent_non_efg_debt)
  end
end
