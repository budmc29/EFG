require "rails_helper"

describe "Lender legal agreement" do
  it "can be enabled and disabled for specific lenders by a CfeAdmin" do
    create(:lender, name: "Acme", new_legal_agreement_signed: false)
    cfe_admin = create(:cfe_admin)

    login_as(cfe_admin)
    visit root_path
    click_link "Manage Lenders"
    click_link "Acme"

    expect(new_legal_agreement_signed).not_to be_checked

    check :lender_new_legal_agreement_signed
    click_button "Update Lender"

    expect(page.current_path).to eq(lenders_path)

    click_link "Acme"

    expect(new_legal_agreement_signed).to be_checked

    uncheck :lender_new_legal_agreement_signed
    click_button "Update Lender"

    expect(page.current_path).to eq(lenders_path)

    click_link "Acme"

    expect(new_legal_agreement_signed).not_to be_checked
  end

  it "prevents lender user from using the app in when
      legal agreement is signed" do
    lender = create(:lender, new_legal_agreement_signed: true)
    lender_user = create(:lender_user, lender: lender, password: "password")

    visit root_path
    submit_sign_in_form(lender_user.username, "password")

    expect(page.current_path).to eq(new_portal_path)
  end

  it "prevents lender admin from using the app when
      legal agreement is signed" do
    lender = create(:lender, new_legal_agreement_signed: true)
    lender_user = create(:lender_admin, lender: lender, password: "password")

    visit root_path
    submit_sign_in_form(lender_user.username, "password")

    expect(page.current_path).to eq(new_portal_path)
  end

  it "allows lender user to use the app when legal agreement is not signed" do
    lender = create(:lender, new_legal_agreement_signed: false)
    lender_user = create(:lender_admin, lender: lender, password: "password")

    visit root_path
    submit_sign_in_form(lender_user.username, "password")

    expect(page.current_path).to eq(root_path)
  end

  it "allows lender admin to use the app when legal agreement is not signed" do
    lender = create(:lender, new_legal_agreement_signed: false)
    lender_user = create(:lender_admin, lender: lender, password: "password")

    visit root_path
    submit_sign_in_form(lender_user.username, "password")

    expect(page.current_path).to eq(root_path)
  end

  def new_legal_agreement_signed
    find("#lender_new_legal_agreement_signed")
  end
end
