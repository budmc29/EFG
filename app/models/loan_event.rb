class LoanEvent
  include StaticAssociation

  attr_accessor :name

  record id: 0 do |r|
    r.name = "Reject"
  end

  record id: 1 do |r|
    r.name = "Accept"
  end

  record id: 2 do |r|
    r.name = "Loan entry"
  end

  record id: 3 do |r|
    r.name = "Cancel loan"
  end

  record id: 4 do |r|
    r.name = "Complete"
  end

  record id: 5 do |r|
    r.name = "Offer scheme facility"
  end

  record id: 6 do |r|
    r.name = "Not progressed"
  end

  record id: 7 do |r|
    r.name = "Guarantee and initial draw"
  end

  record id: 8 do |r|
    r.name = "Not drawn"
  end

  record id: 9 do |r|
    r.name = "Change amount or terms"
  end

  record id: 10 do |r|
    r.name = "Demand to borrower"
  end

  record id: 11 do |r|
    r.name = "Not demanded"
  end

  record id: 12 do |r|
    r.name = "No claim"
  end

  record id: 13 do |r|
    r.name = "Demand against government guarantee"
  end

  record id: 14 do |r|
    r.name = "Loan repaid"
  end

  record id: 15 do |r|
    r.name = "Remove guarantee"
  end

  record id: 16 do |r|
    r.name = "Transfer"
  end

  record id: 17 do |r|
    r.name = "Not closed"
  end

  record id: 18 do |r|
    r.name = "Create claim"
  end

  record id: 19 do |r|
    r.name = "Realise money"
  end

  record id: 20 do |r|
    r.name = "Recovery made"
  end

  record id: 21 do |r|
    r.name = "Legacy loan imported"
  end

  record id: 22 do |r|
    r.name = "Data correction"
  end

  record id: 23 do |r|
    r.name = "Transfer (legacy)"
  end

  record id: 24 do |r|
    r.name = "Data cleanup"
  end

  record id: 25 do |r|
    r.name = "EFG Transfer"
  end

  record id: 26 do |r|
    r.name = "Update lending limi"
  end

  def self.ids
    all.map(&:id)
  end

  Reject = find(0)
  Accept = find(1)
  LoanEntry = find(2)
  Cancel = find(3)
  Complete = find(4)
  OfferSchemeFacility = find(5)
  NotProgressed = find(6)
  Guaranteed = find(7)
  NotDrawn = find(8)
  ChangeAmountOrTerms = find(9)
  DemandToBorrower = find(10)
  NotDemanded = find(11)
  NoClaim = find(12)
  DemandAgainstGovernmentGuarantee = find(13)
  LoanRepaid = find(14)
  RemoveGuarantee = find(15)
  Transfer = find(16)
  NotClosed = find(17)
  CreateClaim = find(18)
  RealiseMoney = find(19)
  RecoveryMade = find(20)
  LegacyLoanImported = find(21)
  DataCorrection = find(22)
  TransferLegacy = find(23)
  DataCleanup = find(24)
  EFGTransfer = find(25)
  UpdateLendingLimit = find(26)
end