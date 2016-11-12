require "rails_helper"

describe LoanTransfer do
  let(:lender) { create(:lender, :with_lending_limit) }

  let!(:loan) do
    create(
      :loan,
      :offered,
      :guaranteed,
      :with_premium_schedule,
      :with_loan_securities,
      :sflg,
      :with_sub_lender,
      lender: lender
    )
  end

  let(:loan_transfer) do
    FactoryGirl.build(
      :loan_transfer,
      amount: loan.amount,
      lender: create(:lender, :with_lending_limit),
      new_amount: loan.amount - Money.new(1000),
      reference: loan.reference,
      facility_letter_date: loan.facility_letter_date,
    )
  end

  describe "validations" do
    it "must have a facility letter date" do
      loan_transfer.facility_letter_date = nil
      expect(loan_transfer).not_to be_valid
    end
  end

  describe "validations" do
    it "has a valid factory" do
      expect(loan_transfer).to be_valid
    end

    it "must have a reference" do
      loan_transfer.reference = nil
      expect(loan_transfer).not_to be_valid
    end

    it "must have an amount" do
      loan_transfer.amount = nil
      expect(loan_transfer).not_to be_valid
    end

    it "must have a new amount" do
      loan_transfer.new_amount = nil
      expect(loan_transfer).not_to be_valid
    end

    it "declaration signed must be true" do
      loan_transfer.declaration_signed = false
      expect(loan_transfer).not_to be_valid
    end

    it "declaration signed must not be blank" do
      loan_transfer.declaration_signed = nil
      expect(loan_transfer).not_to be_valid
    end

    it "must have a lender" do
      loan_transfer.lender = nil
      expect(loan_transfer).not_to be_valid
    end
  end

  describe "#save" do
    let(:original_loan) { loan.reload }

    let(:new_loan) { Loan.last }

    context "when valid" do
      before(:each) do
        loan_transfer.save
      end

      it "transitions original loan to repaid from transfer state" do
        expect(original_loan.state).to eq(Loan::RepaidFromTransfer)
      end

      it "assigns new loan to lender requesting transfer" do
        expect(new_loan.lender).to eq(loan_transfer.lender)
      end

      it "creates new loan with incremented reference number" do
        expect(new_loan.reference).
          to eq(LoanReference.increment(loan.reference))
      end

      it "creates new loan with state 'incomplete'" do
        expect(new_loan.state).to eq(Loan::Incomplete)
      end

      it "creates new loan with amount set to the specified new amount" do
        expect(new_loan.amount).to eq(loan_transfer.new_amount)
      end

      it "creates new loan with no value for branch sort code" do
        expect(new_loan.sortcode).to be_blank
      end

      it "creates new loan with repayment duration of 0" do
        expect(new_loan.repayment_duration).to eq(MonthDuration.new(0))
      end

      it "creates new loan with no value for payment period" do
        expect(new_loan.repayment_frequency).to be_blank
      end

      it "creates new loan with no value for maturity date" do
        expect(new_loan.maturity_date).to be_blank
      end

      it "creates new loan with no value for sub-lender" do
        expect(new_loan.sub_lender).to be_blank
      end

      it "creates new loan with no value for generic fields" do
        (1..5).each do |num|
          expect(new_loan.send("generic#{num}")).to be_blank
        end
      end

      it "creates new loan with no invoice" do
        expect(new_loan.invoice_id).to be_blank
      end

      it "creates a new loan with no lender reference" do
        expect(new_loan.lender_reference).to be_blank
      end

      it "tracks which loan a transferred loan came from" do
        expect(new_loan.transferred_from_id).to eq(loan.id)
      end

      it "assigns new loan to the newest active LendingLimit of the
          lender receiving transfer" do
        expect(new_loan.lending_limit).
          to eq(new_loan.lender.lending_limits.active.first)
      end

      it "nullifies legacy_id field" do
        original_loan.legacy_id = 12_345
        expect(new_loan.legacy_id).to be_nil
      end

      it "creates new loan with modified by set to user requesting transfer" do
        expect(new_loan.modified_by).to eq(loan_transfer.modified_by)
      end

      it "creates new loan with created by set to user requesting transfer" do
        expect(new_loan.created_by).to eq(loan_transfer.modified_by)
      end

      it "copies existing loan securities to new loan" do
        expect(original_loan.loan_security_types).not_to be_empty
        expect(new_loan.loan_security_types).
          to eq(original_loan.loan_security_types)
      end
    end

    context "when new loan amount is greater than the amount of the loan being
             transferred" do
      before(:each) do
        loan_transfer.new_amount = loan.amount + Money.new(100)
      end

      it "returns false" do
        expect(loan_transfer.save).to eq(false)
      end

      it "adds error to base" do
        loan_transfer.save
        expect(loan_transfer.errors[:new_amount]).
          to include(error_string("new_amount.cannot_be_greater"))
      end
    end

    context "when loan being transferred is not in state guaranteed,
             lender demand or repaid" do
      before(:each) do
        loan.update_attribute(:state, Loan::Eligible)
      end

      it "return false" do
        expect(loan_transfer.save).to eq(false)
      end
    end

    context "when loan being transferred belongs to lender
             requesting the transfer" do
      before(:each) do
        loan_transfer.lender = loan.lender
      end

      it "returns false" do
        expect(loan_transfer.save).to eq(false)
      end

      it "adds error to base" do
        loan_transfer.save
        expect(loan_transfer.errors[:base]).
          to include(error_string("base.cannot_transfer_own_loan"))
      end
    end

    context "when the loan being transferred has already been transferred" do
      before(:each) do
        # create new loan with same reference of "loan"
        # but with a incremented version number
        # this means the loan has already been transferred
        incremented_reference = LoanReference.increment(loan.reference)
        create(:loan, :repaid_from_transfer, reference: incremented_reference)
      end

      it "returns false" do
        expect(loan_transfer.save).to eq(false)
      end

      it "adds error to base" do
        loan_transfer.save
        expect(loan_transfer.errors[:base]).
          to include(error_string("base.cannot_be_transferred"))
      end
    end

    context "when no matching loan is found" do
      before(:each) do
        loan_transfer.amount = Money.new(1000)
      end

      it "returns false" do
        expect(loan_transfer.save).to eq(false)
      end

      it "adds error to base" do
        loan_transfer.save
        expect(loan_transfer.errors[:base]).
          to include(error_string("base.cannot_be_transferred"))
      end
    end

    context "when loan is an EFG loan" do
      let!(:loan) do
        create(:loan, :offered, :guaranteed, :with_premium_schedule)
      end

      it "returns false" do
        expect(loan_transfer.save).to eq(false)
      end

      it "adds error to base" do
        loan_transfer.save
        expect(loan_transfer.errors[:base]).
          to include(error_string("base.cannot_be_transferred"))
      end
    end

    context "when lender making transfer can only access EFG scheme loans" do
      let!(:lender) { create(:lender, loan_scheme: Lender::EFG_SCHEME) }

      before(:each) do
        loan_transfer.lender = lender
      end

      it "returns false" do
        expect(loan_transfer.save).to eq(false)
      end

      it "adds error to base" do
        loan_transfer.save
        expect(loan_transfer.errors[:base]).
          to include(error_string("base.cannot_be_transferred"))
      end
    end

    it "creates new loan with a copy of some of the original
        loan's data" do
      loan_transfer.save

      fields_not_copied = %w(
        id lender_id reference state sortcode repayment_duration amount
        repayment_frequency_id maturity_date invoice_id generic1 generic2
        generic3 generic4 generic5 transferred_from_id lending_limit_id
        created_at updated_at legacy_id created_by_id lender_reference
        last_modified_at sub_lender
      )

      fields_to_compare = Loan.column_names - fields_not_copied

      fields_to_compare.each do |field|
        expect(original_loan.send(field)).to eql(new_loan.send(field)),
          "#{field} in transferred loan does not match original loan"
      end
    end

    it "creates a new loan state change record for
        the transferred loan" do
      loan_transfer.save

      expect(original_loan.state_changes.count).to eq(1)

      state_change = original_loan.state_changes.last
      expect(state_change.event).to eq(LoanEvent::Transfer)
      expect(state_change.state).to eq(Loan::RepaidFromTransfer)
    end

    it "creates a new loan state change record for the
        newly created loan" do
      loan_transfer.save

      expect(new_loan.state_changes.count).to eq(1)

      state_change = new_loan.state_changes.last
      expect(state_change.event).to eq(LoanEvent::Transfer)
      expect(state_change.state).to eq(Loan::Incomplete)
    end
  end

  def error_string(key)
    class_key = loan_transfer.class.to_s.underscore
    I18n.t("activemodel.errors.models.#{class_key}.attributes.#{key}")
  end
end
