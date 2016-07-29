class LoanFacility
  include StaticAssociation

  attr_accessor :name

  record id: 1 do |r|
    r.name = "EFG Training"
  end
end
