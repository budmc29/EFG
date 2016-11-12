module ActiveSupport
  module CoreExtensions
    module Date
      module Calculations
        def last_weekday
          date = self
          while !date.weekday?
            date -= 1.day
          end
          date
        end
      end
    end
  end
end

class Date
  include ActiveSupport::CoreExtensions::Date::Calculations
end

