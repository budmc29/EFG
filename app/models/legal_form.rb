class LegalForm
  include StaticAssociation

  attr_accessor :name, :requires_company_registration

  record id: 1 do |r|
    r.name = "Sole Trader"
    r.requires_company_registration = false
  end

  record id: 2 do |r|
    r.name = "Partnership"
    r.requires_company_registration = false
  end

  record id: 3 do |r|
    r.name = "Limited-Liability Partnership (LLP)"
    r.requires_company_registration = true
  end

  record id: 4 do |r|
    r.name = "Private Limited Company (LTD)"
    r.requires_company_registration = true
  end

  record id: 5 do |r|
    r.name = "Public Limited Company (PLC)"
    r.requires_company_registration = true
  end

  record id: 6 do |r|
    r.name = "Other"
    r.requires_company_registration = false
  end

  SoleTrader = find(1)
  Partnership = find(2)
  LLP = find(3)
  LTD = find(4)
  PLC = find(5)
  Other = find(6)
end
