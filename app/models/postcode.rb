class Postcode
  delegate :full?, to: :uk_postcode

  def initialize(value)
    @uk_postcode = UKPostcode.parse(value || "")
  end

  def ==(other)
    to_s == other.to_s
  end

  alias_method :eql?, :==

  def inspect
    "<Postcode raw:#{uk_postcode}>"
  end

  def to_s
    uk_postcode.to_s
  end

  alias_method :raw, :to_s

  private

  attr_reader :uk_postcode
end
