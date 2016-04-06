class EfgRecoveryCalculator
  def initialize(recovery)
    @recovery = recovery
  end

  def realisations_attributable
    [
      recovery.non_linked_security_proceeds + recovery.linked_security_proceeds -
      recovery.outstanding_non_efg_debt,
      Money.new(0),
    ].max
  end

  def amount_due_to_dti
    realisations_attributable * recovery.loan_guarantee_rate
  end

  def amount_due_to_sec_state
    Money.new(0)
  end

  private

  attr_reader :recovery
end
