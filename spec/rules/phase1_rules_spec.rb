require "rails_helper"

describe Phase1Rules do
  describe ".claim_limit_calculator" do
    it "returns the correct calculator class" do
      expect(described_class.claim_limit_calculator).to eql(
        Phase1ClaimLimitCalculator)
    end
  end
end
