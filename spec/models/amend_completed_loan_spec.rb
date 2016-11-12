require "rails_helper"

describe AmendCompletedLoan do
  describe "#initialize" do
    it "raises exception when loan is not completed" do
      loan = build(:loan, :guaranteed)

      expect do
        described_class.new(loan)
      end.to raise_error(IncorrectLoanStateError)
    end
  end

  describe "#save!" do
    it "cancels the existing loan" do
      loan = create(:loan, :completed)
      amend_completed_loan = described_class.new(loan)
      amend_completed_loan.modified_by = build(:lender_user)

      amend_completed_loan.save!

      expect(loan.reload.state).to eq(Loan::Cancelled)
    end

    it "creates a new loan" do
      loan = create(:loan, :completed)
      amend_completed_loan = described_class.new(loan)
      amend_completed_loan.modified_by = build(:lender_user)

      expect do
        amend_completed_loan.save!
      end.to change(Loan, :count).by(1)
    end

    it "creates a new loan with incremented reference" do
      loan = create(:loan, :completed, reference: "8VHFR42+01")
      amend_completed_loan = described_class.new(loan)
      amend_completed_loan.modified_by = build(:lender_user)

      amend_completed_loan.save!

      new_loan = Loan.last
      expect(new_loan.reference).to eq("8VHFR42+02")
    end

    it "creates a new loan that is not a transferred loan" do
      loan = create(:loan, :completed, reference: "8VHFR42+01")
      amend_completed_loan = described_class.new(loan)
      amend_completed_loan.modified_by = build(:lender_user)

      amend_completed_loan.save!

      new_loan = Loan.last
      expect(new_loan).not_to be_created_from_transfer
    end

    it "creates a loan cancelled audit log entry for loan being amended" do
      loan = create(:loan, :completed)
      amend_completed_loan = described_class.new(loan)
      amend_completed_loan.modified_by = build(:lender_user)

      expect do
        amend_completed_loan.save!
      end.to change(loan.state_changes, :count).by(1)
    end

    it "creates a loan amended audit log entry for new loan" do
      loan = create(:loan, :completed)
      amend_completed_loan = described_class.new(loan)
      amend_completed_loan.modified_by = build(:lender_user)

      amend_completed_loan.save!

      new_loan = amend_completed_loan.new_loan
      loan_state_change = new_loan.state_changes.first
      expect(loan_state_change.event).to eq(LoanEvent::AmendCompletedLoan)
    end

    it "raises exception when modified_by is not set" do
      loan = create(:loan, :completed)

      expect do
        described_class.new(loan).save!
      end.to raise_error(ActiveModel::StrictValidationFailed)
    end

    it "rolls back changes when something goes wrong" do
      loan = create(:loan, :completed)
      loan_cancel = build(:loan_cancel)
      allow(LoanCancel).to receive(:new).and_return(loan_cancel)
      allow(loan_cancel).to receive(:save).and_return(false)
      amend_completed_loan = described_class.new(loan)
      amend_completed_loan.modified_by = build(:lender_user)

      expect do
        amend_completed_loan.save!
      end.to raise_error(AmendCompletedLoanError)

      expect(loan.reload.state).to eq(Loan::Completed)
    end
  end
end
