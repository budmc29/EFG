require 'rails_helper'

describe 'Sub Lender Data Correction' do
  include DataCorrectionSpecHelper

  let!(:loan) { FactoryGirl.create(:loan, :guaranteed, lender: current_user.lender) }

  context "lender has sub-lenders" do
    let!(:sub_lender) { FactoryGirl.create(:sub_lender, lender: loan.lender) }
    let!(:old_value) { "old sub-lender" }
    let!(:new_value) { sub_lender.name }

    before do
      loan.update_column(:sub_lender, old_value)
      visit_data_corrections
      click_link "Sub-lender"
    end

    it do
      click_button 'Submit'
      expect(page).to have_content "old sub-lender"
      expect(page).to have_content "a sub-lender must be chosen"

      select new_value, from: 'data_correction_sub_lender'
      click_button 'Submit'

      data_correction = loan.data_corrections.last!
      expect(data_correction.change_type).to eql(ChangeType::SubLender)
      expect(data_correction.created_by).to eql(current_user)
      expect(data_correction.date_of_change).to eql(Date.current)
      expect(data_correction.modified_date).to eql(Date.current)
      expect(data_correction.old_sub_lender).to eql(old_value)
      expect(data_correction.sub_lender).to eql(new_value)

      loan.reload
      expect(loan.sub_lender).to eql(new_value)
      expect(loan.modified_by).to eql(current_user)
    end
  end

  context "lender has no sub-lenders" do
    context "and loan has no existing sub-lender value" do
      it "does not show link to Sub-lender data correction" do
        visit_data_corrections
        expect(page).to_not have_css('a', text: 'Sub-lender')
      end
    end

    context "and loan has sub-lender value" do
      before do
        loan.update_column(:sub_lender, 'ACME')
      end

      it "shows link to Sub-lender data correction" do
        visit_data_corrections
        expect(page).to have_css('a', text: 'Sub-lender')
      end
    end
  end
end
