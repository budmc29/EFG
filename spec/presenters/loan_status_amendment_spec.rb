require "rails_helper"

describe LoanStatusAmendment do
  describe "initializing with not yet guaranteed loan" do
    it "raises exception" do
      [
        :rejected, :eligible, :cancelled, :incomplete, :completed, :offered
      ].each do |loan_state|
        loan = FactoryGirl.build(:loan, loan_state)

        expect do
          LoanStatusAmendment.new(loan)
        end.to raise_error(IncorrectLoanStateError)
      end
    end
  end

  describe "validations" do
    let(:loan_status_amendment) { FactoryGirl.build(:loan_status_amendment) }

    it "has a valid factory" do
      expect(loan_status_amendment).to be_valid
    end

    it "can have a blank status_amendment_type" do
      loan_status_amendment.status_amendment_type = nil
      expect(loan_status_amendment).to be_valid
    end

    it "must have an allowed status_amendment_type" do
      loan_status_amendment.status_amendment_type = "Foo"
      expect(loan_status_amendment).not_to be_valid
    end
  end

  describe "#save" do
    it "persists the amendment type and notes on the loan" do
      loan_status_amendment = FactoryGirl.build(
        :loan_status_amendment,
        status_amendment_type: "Administrative",
        status_amendment_notes: "A mistake was made.",
      )

      loan_status_amendment.save

      loan = loan_status_amendment.loan
      expect(loan.status_amendment_type).to eql(
        LoanStatusAmendment::ADMINISTRATIVE)
      expect(loan.status_amendment_notes).to eql("A mistake was made.")
    end
  end
end
