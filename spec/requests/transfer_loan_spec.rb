require "rails_helper"

describe "Transfer a loan" do
  let(:lender) { create(:lender, :with_lending_limit) }
  let(:current_user) { create(:lender_user, lender: lender) }
  let(:loan) do
    create(:loan, :offered, :guaranteed, :with_premium_schedule, :sflg)
  end

  before(:each) do
    login_as(current_user, scope: :user)
    visit root_path
    click_link "Transfer a Loan"
  end

  it "should transfer loan from one lender to another" do
    fill_in "loan_transfer_reference", with: loan.reference
    fill_in "loan_transfer_amount", with: loan.amount.to_s
    fill_in "loan_transfer_facility_letter_date",
            with: loan.facility_letter_date.strftime("%d/%m/%Y")
    fill_in "loan_transfer_new_amount", with: loan.amount - Money.new(500)
    choose "loan_transfer_declaration_signed_true"

    click_button "Transfer Loan"

    expect(page).to have_content(
      "This page provides confirmation that the loan has been transferred."
    )

    # Check original loan and new loan
    loan.reload
    expect(loan.state).to eq(Loan::RepaidFromTransfer)
    expect(loan.modified_by).to eq(current_user)

    transferred_loan = Loan.last
    expect(transferred_loan.transferred_from_id).to eq(loan.id)
    expect(transferred_loan.reference).
      to eq(LoanReference.new(loan.reference).increment)
    expect(transferred_loan.state).to eq(Loan::Incomplete)
    expect(transferred_loan.business_name).to eq(loan.business_name)
    expect(transferred_loan.amount).to eq(loan.amount - Money.new(500))
    expect(transferred_loan.created_by).to eq(current_user)
    expect(transferred_loan.modified_by).to eq(current_user)

    # verify correct loan entry form is shown
    click_link "Loan Entry"
    expect(current_path).
      to eq(new_loan_transferred_entry_path(transferred_loan))
  end

  it "should display error when loan to transfer is not found" do
    fill_in "loan_transfer_reference", with: "wrong"
    fill_in "loan_transfer_amount", with: loan.amount.to_s
    fill_in "loan_transfer_facility_letter_date",
            with: loan.facility_letter_date.strftime("%d/%m/%Y")
    fill_in "loan_transfer_new_amount", with: loan.amount - Money.new(500)
    choose "loan_transfer_declaration_signed_true"

    click_button "Transfer Loan"

    expected_error = I18n.t(
      :cannot_be_transferred,
      scope: "activemodel.errors.models.loan_transfer.attributes.base"
    )
    expect(page).to have_content(expected_error)
  end

  it "should display error when loan to transfer is an EFG loan" do
    # change loan to EFG scheme
    loan.loan_scheme = "E"
    loan.save!

    fill_in "loan_transfer_reference", with: loan.reference
    fill_in "loan_transfer_amount", with: loan.amount.to_s
    fill_in "loan_transfer_facility_letter_date",
            with: loan.facility_letter_date.strftime("%d/%m/%Y")
    fill_in "loan_transfer_new_amount", with: loan.amount - Money.new(500)
    choose "loan_transfer_declaration_signed_true"

    click_button "Transfer Loan"

    expected_error = I18n.t(
      :cannot_be_transferred,
      scope: "activemodel.errors.models.loan_transfer.attributes.base"
    )
    expect(page).to have_content(expected_error)
  end
end
