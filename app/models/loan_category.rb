class LoanCategory
  include StaticAssociation

  attr_accessor :name, :requires_company_registration

  record id: 1 do |r|
    r.name = "Type A - New Term Loan with No Security"
  end

  record id: 2 do |r|
    r.name = "Type B - New Term Loan with Partial Security"
  end

  record id: 3 do |r|
    r.name = "Type C - New Term Loan for Overdraft Refinancing"
  end

  record id: 4 do |r|
    r.name = "Type D - New Term Loan for Debt Consolidation or Refinancing"
  end

  record id: 5 do |r|
    r.name = "Type E - Revolving Credit Guarantee"
  end

  record id: 6 do |r|
    r.name = "Type F - Invoice Finance Guarantee Facility"
  end

  record id: 7 do |r|
    r.name = "Type G - Revolving Credit Refinance Guarantee"
  end

  record id: 8 do |r|
    r.name = "Type H - Invoice Finance Refinance Guarantee"
  end

  TypeA = find(1)
  TypeB = find(2)
  TypeC = find(3)
  TypeD = find(4)
  TypeE = find(5)
  TypeF = find(6)
  TypeG = find(7)
  TypeH = find(8)
end
