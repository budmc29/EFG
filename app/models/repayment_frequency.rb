class RepaymentFrequency
  include StaticAssociation

  attr_accessor :name, :months_per_repayment_period

  record id: 0 do |r|
    r.name = "Legacy Monthly"
    r.months_per_repayment_period = 1
  end

  record id: 1 do |r|
    r.name = "Annually"
    r.months_per_repayment_period = 12
  end

  record id: 2 do |r|
    r.name = "Six Monthly"
    r.months_per_repayment_period = 6
  end

  record id: 3 do |r|
    r.name = "Quarterly"
    r.months_per_repayment_period = 3
  end

  record id: 4 do |r|
    r.name = "Monthly"
    r.months_per_repayment_period = 1
  end

  record id: 5 do |r|
    r.name = "Interest Only - Single Repayment on Maturity"
  end

  def self.selectable
    all.dup.tap do |repayment_frequencies|
      repayment_frequencies.delete(LegacyMonthly)
    end
  end

  LegacyMonthly = find(0)
  Annually = find(1)
  SixMonthly = find(2)
  Quarterly = find(3)
  Monthly = find(4)
  InterestOnly = find(5)
end
