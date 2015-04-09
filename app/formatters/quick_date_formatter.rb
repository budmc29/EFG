class QuickDateFormatter
  def self.format(value)
    value
  end

  def self.parse(value)
    case value
    when nil
      nil
    when Date, Time
      value.to_date
    else
      match = value.to_s.match(%r{^(\d{1,2})/(\d{1,2})/(\d{2,4})$})
      day, month, year = match[1..3] if match

      return unless match
      year = "20#{year}" if year.length == 2

      begin
        Date.new(year.to_i, month.to_i, day.to_i)
      rescue ArgumentError
      end
    end
  end
end
