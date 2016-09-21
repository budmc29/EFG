class NextPremiumCollection
  def initialize(from_date:, to_date:)
    @from_date = from_date
    @to_date = to_date
  end

  def date
    from_date.advance(
      months: total_months_from_start_to_next_collection
    )
  end

  def total_months_from_start_to_next_collection
    total_months = (months_between_from_and_to_date.to_f / 3).ceil * 3

    if beginning_of_month?(total_months)
      total_months += 3
    end

    total_months
  end

  private

  attr_reader :from_date, :to_date

  def to_date_total_months
    to_date.year * 12 + to_date.month
  end

  def from_date_total_months
    from_date.year * 12 + from_date.month
  end

  def months_between_from_and_to_date
    to_date_total_months - from_date_total_months
  end

  def beginning_of_month?(total_months)
    to_date.beginning_of_month ==
      from_date.advance(months: total_months).beginning_of_month
  end
end
