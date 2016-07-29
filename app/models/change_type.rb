class ChangeType
  include StaticAssociation

  attr_accessor :name

  record id: "1" do |r|
    r.name = "Business name"
  end

  record id: "2" do |r|
    r.name = "Capital repayment holiday"
  end

  record id: "3" do |r|
    r.name = "Change repayments"
  end

  record id: "4" do |r|
    r.name = "Extend term"
  end

  record id: "5" do |r|
    r.name = "Lender demand satisfied"
  end

  record id: "6" do |r|
    r.name = "Lump sum repayment"
  end

  record id: "7" do |r|
    r.name = "Record agreed draw"
  end

  record id: "8" do |r|
    r.name = "Reprofile draws"
  end

  record id: "9" do |r|
    r.name = "Data correction"
  end

  record id: "a" do |r|
    r.name = "Decrease term"
  end

  record id: "b" do |r|
    r.name = "Repayment frequency"
  end

  record id: "c" do |r|
    r.name = "Postcode"
  end

  record id: "d" do |r|
    r.name = "Lender Reference"
  end

  record id: "e" do |r|
    r.name = "Trading Name"
  end

  record id: "f" do |r|
    r.name = "Sortcode"
  end

  record id: "g" do |r|
    r.name = "Trading Date"
  end

  record id: "h" do |r|
    r.name = "Company Registration"
  end

  record id: "i" do |r|
    r.name = "Generic Fields"
  end

  record id: "j" do |r|
    r.name = "Sub-lender"
  end

  BusinessName = find("1")
  CapitalRepaymentHoliday = find("2")
  ChangeRepayments = find("3")
  ExtendTerm = find("4")
  LenderDemandSatisfied = find("5")
  LumpSumRepayment = find("6")
  RecordAgreedDraw = find("7")
  ReprofileDraws = find("8")
  DataCorrection = find("9")
  DecreaseTerm = find("a")
  RepaymentFrequency = find("b")
  Postcode = find("c")
  LenderReference = find("d")
  TradingName = find("e")
  Sortcode = find("f")
  TradingDate = find("g")
  CompanyRegistration = find("h")
  GenericFields = find("i")
  SubLender = find("j")
end
