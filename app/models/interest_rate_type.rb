class InterestRateType
  include StaticAssociation

  attr_accessor :name

  record id: 1 do |r|
    r.name = "Variable"
  end

  record id: 2 do |r|
    r.name = "Fixed"
  end
end
