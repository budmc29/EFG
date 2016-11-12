require "rails_helper"

describe NextPremiumCollection do
  describe "#date" do
    it "returns the date of the next premium collection for the given dates" do
      next_premium_collection = described_class.new(
        from_date: Date.new(2016, 1, 8),
        to_date: Date.new(2016, 9, 12)
      )

      expect(next_premium_collection.date).to eq(Date.new(2016, 10, 8))
    end
  end

  describe "#total_months_from_start_to_next_collection" do
    it "returns the number of months since the loan was initially drawn to the
        next premium collection month" do
      next_premium_collection = described_class.new(
        from_date: Date.new(2015, 4, 12),
        to_date: Date.new(2016, 9, 1)
      )

      expect(
        next_premium_collection.total_months_from_start_to_next_collection
      ).to eq(18)
    end
  end
end
