class MoneyFormatter
  def initialize(currency = 'GBP')
    @currency = currency
  end

  attr_reader :currency

  def format(value)
    Money.new(value, currency) if value
  end

  def parse(value)
    Monetize.parse(value).cents if value.present?
  end
end
