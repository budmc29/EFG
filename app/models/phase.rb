class Phase
  include StaticAssociation

  attr_accessor :euro_conversion_rate, :starts_on, :ends_on

  record id: 1 do |r|
    r.euro_conversion_rate = BigDecimal.new("1.04058")
    r.starts_on = Date.new(2009, 1, 14)
    r.ends_on = Date.new(2010, 3, 31)
  end

  record id: 2 do |r|
    r.euro_conversion_rate = BigDecimal.new("1.04058")
    r.starts_on = Date.new(2010, 4, 1)
    r.ends_on = Date.new(2011, 3, 31)
  end

  record id: 3 do |r|
    r.euro_conversion_rate = BigDecimal.new("1.04058")
    r.starts_on = Date.new(2011, 4, 1)
    r.ends_on = Date.new(2012, 3, 31)
  end

  record id: 4 do |r|
    r.euro_conversion_rate = BigDecimal.new("1.19740")
    r.starts_on = Date.new(2012, 4, 1)
    r.ends_on = Date.new(2013, 3, 31)
  end

  record id: 5 do |r|
    r.euro_conversion_rate = BigDecimal.new("1.22850")
    r.starts_on = Date.new(2013, 4, 1)
    r.ends_on = Date.new(2014, 3, 31)
  end

  record id: 6 do |r|
    r.euro_conversion_rate = BigDecimal.new("1.20744")
    r.starts_on = Date.new(2014, 4, 1)
    r.ends_on = Date.new(2015, 3, 31)
  end

  record id: 7 do |r|
    r.euro_conversion_rate = BigDecimal.new("1.20744")
    r.starts_on = Date.new(2015, 4, 1)
    r.ends_on = Date.new(2016, 3, 31)
  end

  record id: 8 do |r|
    r.euro_conversion_rate = BigDecimal.new("1.20744")
    r.starts_on = Date.new(2016, 4, 1)
    r.ends_on = Date.new(2017, 3, 31)
  end

  def self.for_date(date)
    Phase.all.detect { |p| date.between?(p.starts_on, p.ends_on) }
  end

  def lending_limits
    LendingLimit.where(phase_id: id)
  end

  def name
    "Phase #{id} (#{financial_year})"
  end

  def rules
    "Phase#{id}Rules".constantize
  end

  # The financial year for which the Phase operates for. Phase 1 is slightly
  # different, starting on 2009-01-14, but it was deemed for consistency that
  # it was acceptable to display it as FY 2009/10.
  def financial_year
    "FY #{starts_on.strftime("%Y")}/#{ends_on.strftime("%y")}"
  end

  def type
    LoanTypes::EFG
  end
end
