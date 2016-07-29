class CancelReason
  include StaticAssociation

  attr_accessor :name

  record id: 1 do |r|
    r.name = "Borrower does not require loan"
  end

  record id: 2 do |r|
    r.name = "Lender credit rejected"
  end

  record id: 3 do |r|
    r.name = "Alternative loan processed"
  end

  record id: 4 do |r|
    r.name = "Other"
  end
end
