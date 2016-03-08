require "rails_helper"

describe LoanSettlementAdjustment do
  subject(:adjustment) { FactoryGirl.build(:loan_settlement_adjustment, attrs) }

  let(:attrs) { { amount: "100.00", date: "23/03/16" } }

  describe "validations" do
    it "has a valid factory" do
      expect(adjustment).to be_valid
    end

    it "must have a created_by user" do
      adjustment.created_by = nil
      expect(adjustment).not_to be_valid
    end

    it "must have an amount" do
      attrs[:amount] = nil
      expect(adjustment).not_to be_valid
    end

    it "must have a date" do
      attrs[:date] = nil
      expect(adjustment).not_to be_valid
    end

    it "must have a positive amount" do
      attrs[:amount] = "0"
      expect(adjustment).not_to be_valid
    end
  end
end
