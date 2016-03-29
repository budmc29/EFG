require "rails_helper"

describe LoanAlerts::NotClosed do
  let(:lender) { FactoryGirl.create(:lender) }
  let(:not_closed) { described_class.new(lender) }

  describe "#loans" do
    let!(:unclosed_sflg_loan1) do
      FactoryGirl.create(
        :loan,
        :sflg,
        :guaranteed,
        lender: lender,
        maturity_date: 22.weeks.ago.to_date)
    end

    let!(:unclosed_sflg_loan2) do
      FactoryGirl.create(
        :loan,
        :sflg,
        :guaranteed,
        lender: lender,
        maturity_date: 21.weeks.ago.to_date)
    end

    let!(:unclosed_sflg_loan3) do
      FactoryGirl.create(
        :loan,
        :sflg,
        :guaranteed,
        lender: lender,
        maturity_date: 20.weeks.ago.to_date)
    end

    let!(:unclosed_efg_loan1) do
      FactoryGirl.create(
        :loan,
        :efg,
        :guaranteed,
        lender: lender,
        maturity_date: 11.weeks.ago.to_date)
    end

    let!(:unclosed_efg_loan2) do
      FactoryGirl.create(
        :loan,
        :efg,
        :guaranteed,
        lender: lender,
        maturity_date: 12.weeks.ago.to_date)
    end

    let!(:unclosed_efg_loan3) do
      FactoryGirl.create(
        :loan,
        :efg,
        :guaranteed,
        lender: lender,
        maturity_date: 10.weeks.ago.to_date)
    end

    let!(:already_closed_loan) do
      FactoryGirl.create(
        :loan,
        :efg,
        :guaranteed,
        lender: lender,
        maturity_date: 15.weeks.ago.to_date)
    end

    let!(:different_lender_unclosed_loan) do
      FactoryGirl.create(
        :loan,
        :efg,
        :guaranteed,
        maturity_date: 10.weeks.ago.to_date)
    end

    it "fetches the alerting loans from both guaranteed and offered,
        and sorts by days remaining" do
      expected_loan_ids = [unclosed_efg_loan2.id,
                           unclosed_efg_loan1.id,
                           unclosed_efg_loan3.id,
                           unclosed_sflg_loan1.id,
                           unclosed_sflg_loan2.id,
                           unclosed_sflg_loan3.id]

      expect(not_closed.loans.map(&:id)).to eq(expected_loan_ids)
    end

    it "has remaining days before each loan is auto-removed" do
      expect(not_closed.loans[0].days_remaining).to eql(5)
      expect(not_closed.loans[1].days_remaining).to eql(10)
      expect(not_closed.loans[2].days_remaining).to eql(15)
      expect(not_closed.loans[3].days_remaining).to eql(20)
      expect(not_closed.loans[4].days_remaining).to eql(25)
      expect(not_closed.loans[5].days_remaining).to eql(30)
    end
  end
end
