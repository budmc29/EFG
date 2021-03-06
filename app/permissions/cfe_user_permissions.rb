module CfeUserPermissions
  def can_create?(resource)
    [
      ClaimLimitsCsvExport,
      DataCorrection,
      Invoice,
      LoanRemoveGuarantee,
      RealisationAdjustment,
      RealisationsReport,
      RealisationStatement,
      LoanReport,
      LoanAuditReport,
      RecoveriesReport,
      RealisationStatement,
      SettlementAdjustment,
      LoanStatusAmendment,
    ].include?(resource)
  end

  def can_destroy?(resource)
    false
  end

  def can_update?(resource)
    false
  end

  def can_enable?(resource)
    can_update?(resource)
  end

  def can_disable?(resource)
    can_update?(resource)
  end

  def can_unlock?(resource)
    can_update?(resource)
  end

  def can_view?(resource)
    [
      Adjustment,
      DataCorrection,
      Invoice,
      Loan,
      LoanAlerts,
      LoanChange,
      LoanRemoveGuarantee,
      LoanStates,
      LoanModification,
      PremiumSchedule,
      RealisationStatement,
      Search
    ].include?(resource)
  end
end
