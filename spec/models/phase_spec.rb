require "rails_helper"

describe Phase do
  describe ".for_date" do
    it "returns the phase for the specified date" do
      date = Date.new(2015, 4, 1)
      phase = Phase.for_date(date)

      expect(phase).to eql(Phase.find(7))
    end

    it "returns nil when there is no phase for the specified date" do
      date = Date.new(2000, 4, 1)
      phase = Phase.for_date(date)
      expect(phase).to be_nil
    end
  end
end
