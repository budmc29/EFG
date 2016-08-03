require "rails_helper"

describe "Fixed Repayment Premium Schedule" do
  it "allows configuring of premium schedule with fixed repayment amount" do
    lender_user = FactoryGirl.create(:lender_user)
    lender = lender_user.lender
    loan = FactoryGirl.create(
      :loan,
      :guaranteed,
      lender: lender,
      amount: Money.new(10_000_00)
    )

    login_as(lender_user)

    visit loan_path(loan)
    click_link "Generate Premium Schedule"

    fill_in :premium_schedule_initial_draw_amount, with: "10000"
    choose :premium_schedule_repayment_profile_fixed_amount
    fill_in :premium_schedule_fixed_repayment_amount, with: "1000"
    click_button "Submit"

    expect(page.current_path).to eq(loan_premium_schedule_path(loan))
    expect(page).to have_content("Repayment Amount")
  end
end
