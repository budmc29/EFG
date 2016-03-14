require "rails_helper"

describe "Demanded loan" do
  let(:current_user) { FactoryGirl.create(:lender_user) }

  let(:loan) do
    FactoryGirl.create(:loan, :demanded, lender: current_user.lender)
  end

  before do
    login_as(current_user)
  end

  it "can transition to repaid" do
    visit loan_path(loan)

    expect(change_to_repaid_button).to have_javascript_confirmation(
      "Are you sure you want to repay this loan?")
    change_to_repaid_button.click

    fill_in :loan_repay_repaid_on, with: Date.current.to_s(:screen)
    click_button "Submit"

    expect(current_path).to eq(loan_path(loan))
  end

  def change_to_repaid_button
    find(".btn-repay-loan")
  end
end
