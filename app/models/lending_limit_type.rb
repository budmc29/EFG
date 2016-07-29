class LendingLimitType
  include StaticAssociation

  attr_accessor :name

  record id: 1 do |r|
    r.name = "Annual"
  end

  record id: 2 do |r|
    r.name = "Specific"
  end

  Annual = find(1)
  Specific = find(2)
end
