require "rails_helper"

describe "Demanded loan" do
  let(:current_user) { FactoryGirl.create(:lender_user) }

  let(:loan) do
    FactoryGirl.create(:loan, :demanded, lender: current_user.lender)
  end

  before do
    login_as(current_user)
  end

  it "can transition to lender demand" do
    visit loan_path(loan)

    expect(change_to_lender_demand_button).to have_javascript_confirmation(
      "Are you sure you want to revert this loan to lender demand?")
    change_to_lender_demand_button.click

    expect(current_path).to eq(loan_path(loan))
  end

  def change_to_lender_demand_button
    find(".btn-revert-to-lender-demand")
  end
end
