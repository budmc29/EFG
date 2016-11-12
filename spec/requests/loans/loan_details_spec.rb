require "rails_helper"

describe "Loan details" do
  describe "Summary" do
    context "as a lender user" do
      let(:current_user) { FactoryGirl.create(:lender_user) }
      let(:loan) do
        FactoryGirl.create(:loan, :transferred, lender: current_user.lender)
      end

      before(:each) do
        login_as(current_user, scope: :user)

        visit loan_path(loan)
      end

      it "shows the loan state" do
        expect(find(".loan-summary")).to have_content(loan.state.humanize)
      end

      it "shows the loan amount" do
        expect(find(".loan-summary")).to have_content(loan.amount.format)
      end

      it "shows the business name" do
        expect(find(".loan-summary")).to have_content(loan.business_name)
      end

      it "shows when it was last modified" do
        expect(find(".loan-summary")).to have_content(
          loan.updated_at.strftime("%d/%m/%Y %H:%M:%S"))
      end

      it "shows who it was last modified by" do
        expect(find(".loan-summary")).to have_content(loan.modified_by.name)
      end

      it "does not display the lender name" do
        expect(find(".loan-summary")).not_to have_content(loan.lender.name)
      end
    end

    context "as any other user" do
      let(:current_lender) { FactoryGirl.create(:lender) }
      let(:current_user) { FactoryGirl.create(:cfe_user) }
      let(:loan) do
        FactoryGirl.create(:loan, :transferred, lender: current_lender)
      end

      before(:each) do
        login_as(current_user, scope: :user)

        visit loan_path(loan)
      end

      it "displays the lender name" do
        expect(find(".loan-summary")).to have_content(loan.lender.name)
      end
    end
  end

  describe "CSV export" do
    let(:current_user) { FactoryGirl.create(:lender_user) }
    let(:loan) do
      FactoryGirl.create(:loan, :transferred, lender: current_user.lender)
    end

    before(:each) do
      login_as(current_user, scope: :user)
    end

    it "can export loan data as CSV from loan summary page" do
      visit loan_path(loan)

      click_link "Export CSV"

      expect(page.current_url).to eq(loan_url(loan, format: "csv"))
    end

    it "can export loan data as CSV from loan details page" do
      visit details_loan_path(loan)

      click_link "Export CSV"

      expect(page.current_url).to eq(details_loan_url(loan, format: "csv"))
    end
  end
end
