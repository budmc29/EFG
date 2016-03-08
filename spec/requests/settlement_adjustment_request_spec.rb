require "rails_helper"

describe "Making a settlement adjustment" do
  let(:current_user) { FactoryGirl.create(:cfe_user) }

  let(:loan) do
    FactoryGirl.create(:loan, :settled, settled_amount: Money.new(10_000_00))
  end

  before do
    login_as(current_user, scope: :user)
    navigate_to_settlement_adjustment_form
  end

  it "succeeds with valid values" do
    fill_in :loan_settlement_adjustment_amount, with: "100.00"
    fill_in :loan_settlement_adjustment_date, with: "23/03/2016"
    fill_in :loan_settlement_adjustment_notes, with: "Human error"
    click_on "Submit"

    click_link 'Loan Details'
    expect(page).to have_detail_row("Settlement adjustment amount", "£100.00")
    expect(page).to have_detail_row("Settled amount", "£10,100.00")
  end

  it "fails with invalid values" do
    fill_in :loan_settlement_adjustment_amount, with: "0"

    expect do
      click_on "Submit"
    end.not_to change(SettlementAdjustment, :count)

    expect(page).to have_content("must be greater than 0")
  end

  def navigate_to_settlement_adjustment_form
    visit loan_path(loan)
    click_on "Make a Settlement Adjustment"
  end
end
