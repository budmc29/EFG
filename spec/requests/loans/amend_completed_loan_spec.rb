require "rails_helper"

describe "Amend completed loan" do
  it "allows changing loan entry details of completed loan" do
    lender_user = create(:lender_user)
    create(
      :loan,
      :completed,
      reference: "8VHFR42+01",
      lender: lender_user.lender
    )
    login_as(lender_user)

    visit loan_state_path(:completed)
    click_on "8VHFR42+01"
    click_on "Amend Loan Details"
    click_on "Confirm"

    new_loan = Loan.last
    expect(page.current_path).to eq(new_loan_entry_path(new_loan))
    expect(page).to have_content("8VHFR42+02")
  end

  it "allows lender to change their mind about amending loan details" do
    lender_user = create(:lender_user)
    loan = create(:loan, :completed, lender: lender_user.lender)
    login_as(lender_user)

    visit loan_state_path(:completed)
    click_on loan.reference
    click_on "Amend Loan Details"
    click_on "Cancel"

    expect(page.current_path).to eq(loan_path(loan))
  end
end
