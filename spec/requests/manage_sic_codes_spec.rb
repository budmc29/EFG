require "rails_helper"

describe "Manage SIC codes" do
  it "allows Cfe Admin to add SIC codes" do
    cfe_admin = create(:cfe_admin)

    login_as(cfe_admin, scope: :user)
    visit root_path

    click_link "Manage SIC Codes"
    click_link "New SIC Code"

    fill_in :sic_code_code, with: "ABC123"
    fill_in :sic_code_description, with: "Some new SIC code"
    check :sic_code_public_sector_restricted
    fill_in :sic_code_state_aid_threshold, with: "50000"
    click_button "Create Sic code"

    expect(page).to have_content("SIC code ABC123 successfully created")
    within "#sic_code_#{SicCode.last.id}" do
      expect(page).to have_content("ABC123")
    end
  end

  it "allows Cfe Admin to update SIC codes" do
    sic_code = create(:sic_code, code: "DEF456")
    cfe_admin = create(:cfe_admin)

    login_as(cfe_admin, scope: :user)
    visit root_path

    click_link "Manage SIC Codes"
    click_link "DEF456"

    fill_in :sic_code_code, with: "DEF4567"
    uncheck :sic_code_active
    click_button "Update Sic code"

    expect(page).to have_content("SIC code DEF4567 successfully updated")
    within "#sic_code_#{sic_code.id}" do
      expect(page).to have_content("DEF4567")
    end
  end
end
