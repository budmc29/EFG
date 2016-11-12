require "rails_helper"

describe "Repayment Profile loan change" do
  it "allows changing a loan from a Repay to Zero profile to a
      Repayment Amount profile" do
    lender_user = create(:lender_user)
    loan = create(
      :loan,
      :guaranteed,
      lender: lender_user.lender,
      amount: Money.new(40_000_00),
    )
    create(:premium_schedule, :repay_to_zero, loan: loan)

    login_as(lender_user)
    visit loan_path(loan)
    open_repayment_profile_loan_change_form

    fill_form(
      :loan_change,
      date_of_change: "01/08/16",
      fixed_repayment_amount: "1950.00",
      initial_draw_amount: "30000.00",
      initial_capital_repayment_holiday: 0,
    )
    choose :loan_change_repayment_profile_fixed_amount
    click_button "Submit"

    expect(page.current_path).to eq(loan_path(loan))
  end

  it "shows validation errors when form is incomplete" do
    lender_user = create(:lender_user)
    loan = create(
      :loan,
      :guaranteed,
      lender: lender_user.lender,
    )
    create(:premium_schedule, :repay_to_zero, loan: loan)

    login_as(lender_user)
    visit loan_path(loan)
    open_repayment_profile_loan_change_form

    click_button "Submit"

    expect(page.current_path).
      to eq(loan_loan_changes_path(loan))
  end

  def open_repayment_profile_loan_change_form
    click_link "Change Amount or Terms"
    click_link "Repayment Profile"
  end
end
