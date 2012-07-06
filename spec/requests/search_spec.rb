require 'spec_helper'

describe "search" do
  let(:current_lender) { FactoryGirl.create(:lender) }
  let(:current_user) { FactoryGirl.create(:lender_user, lender: current_lender) }
  let!(:loan1) { FactoryGirl.create(:loan, :guaranteed, reference: "9BCI17R-01", lender: current_lender) }
  let!(:loan2) { FactoryGirl.create(:loan, :guaranteed, reference: "9BCI17R-02", lender: current_lender, business_name: "Inter-slice") }

  before do
    login_as(current_user, scope: :user)
  end

  it "should find a specific loan" do
    visit new_search_path

    within "#search" do
      fill_in "Business Name", with: loan1.business_name
      fill_in "Trading Name", with: loan1.trading_name
      fill_in "Company Registration", with: loan1.company_registration
      select "Guaranteed", from: "State"
      click_button "Search"
    end

    page.should have_content("1 result found")
    page.should have_content(loan1.reference)
    page.should_not have_content(loan2.reference)
  end

  it "should find multiple loans" do
    visit new_search_path

    within "#search" do
      select "Guaranteed", from: "State"
      click_button "Search"
    end

    page.should have_content("2 results found")
    page.should have_content(loan1.reference)
    page.should have_content(loan2.reference)
  end
end