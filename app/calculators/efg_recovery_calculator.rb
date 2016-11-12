class EfgRecoveryCalculator
  def initialize(recovery)
    @recovery = recovery
  end

  def realisations_attributable
    recovery.linked_security_proceeds +
      non_linked_security_proceeds_efg_debt_amount
  end

  def amount_due_to_dti
    realisations_attributable * recovery.loan_guarantee_rate
  end

  # This method isn't relevant to EFG but is
  # needed to maintain a consistent interface with
  # other recovery calculators
  def amount_due_to_sec_state
    Money.new(0)
  end

  private

  attr_reader :recovery

  def value_of_efg_debt
    recovery.dti_demand_outstanding
  end

  # All proceeds from linked security go to repay
  # EFG lending first. 75% (current guarantee rate) of
  # this linked security is refunded to BIS.
  #
  # The remainder represents how much EFG debt is left
  def remaining_efg_debt
    [
      value_of_efg_debt - recovery.linked_security_proceeds,
      Money.new(0),
    ].max
  end

  # Any non-linked security proceeds are applied
  # first to any non-EFG borrowing taken out prior to or
  # simultaneous with the EFG facility.
  #
  # Any remaining non-linked security is split between
  # paying off any remaining EFG and non-EFG debt.
  def remaining_non_linked_security_proceeds
    [
      recovery.non_linked_security_proceeds -
        recovery.outstanding_prior_non_efg_debt,
      Money.new(0),
    ].max
  end

  # The amount of remaining non-linked security proceeds
  # that goes towards paying of EFG debt
  def non_linked_security_proceeds_efg_debt_amount
    remaining_non_linked_security_proceeds *
      efg_proportion_of_remaining_securities
  end

  # Calculates what proportion of the remaining non-linked
  # security goes towards paying off the remaining EFG debt
  #
  # This is:
  # the total remaining EFG debt divided by the sum of
  # total remaining EFG debt and the subsequent non-EFG
  # debt balance
  def efg_proportion_of_remaining_securities
    return 0 unless has_debt?

    efg_debt_proportion = remaining_efg_debt / (
                            remaining_efg_debt +
                            recovery.outstanding_subsequent_non_efg_debt)

    efg_debt_proportion.round(2)
  end

  def has_debt?
    [
      remaining_efg_debt,
      recovery.outstanding_subsequent_non_efg_debt,
    ].any? { |amount| amount != Money.new(0) }
  end
end
