require "rails_helper"

describe RevertDemandedLoan do
  describe "#save" do
    context "when loan is Demanded" do
      let(:loan) { FactoryGirl.create(:loan, :demanded) }

      before do
        described_class.new(loan).save
      end

      it "updates to the loan's state to Lender Demand" do
        loan.reload
        expect(loan.state).to eq(Loan::LenderDemand)
      end
    end
  end

  describe "#initialize" do
    context "when loan is not Demanded" do
      let(:loan) { FactoryGirl.create(:loan, :lender_demand) }

      it "raises exception" do
        expect do
          described_class.new(loan)
        end.to raise_error(IncorrectLoanStateError)
      end
    end
  end
end
