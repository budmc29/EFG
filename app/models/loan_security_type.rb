class LoanSecurityType
  include StaticAssociation

  attr_accessor :name

  record id: 1 do |r|
    r.name = "Residential property other than a principal private residence"
  end

  record id: 2 do |r|
    r.name = "Commercial property"
  end

  record id: 3 do |r|
    r.name = "Shares and other securities"
  end

  record id: 4 do |r|
    r.name = "Cash on deposit"
  end

  record id: 5 do |r|
    r.name = "Plant, machinery or other business equipment"
  end

  record id: 6 do |r|
    r.name = "Raw materials or stock"
  end

  record id: 7 do |r|
    r.name = "Personal vehicle, boat or other asset"
  end

  record id: 8 do |r|
    r.name = "Personal life insurance or other policy"
  end

  record id: 9 do |r|
    r.name = "Debenture or Floating Charge"
  end

  record id: 10 do |r|
    r.name = "Other"
  end
end
