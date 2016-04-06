class LegacySflgRecoveryCalculator < SflgRecoveryCalculator
  private

  def claimable_amount
    recovery.dti_amount_claimed / recovery.loan_guarantee_rate
  end

  def magic_number
    claimable_amount / (claimable_amount +
                        recovery.total_liabilities_behind)
  end
end
