require 'spec_helper'

describe GenericFieldsDataCorrection do

  let(:loan_with_generic_info) { FactoryGirl.create(:loan, :guaranteed, :loan_with_generic_info) }
  let(:loan_without_generic_info) { FactoryGirl.create(:loan, :guaranteed, :loan_without_generic_info) }

  describe 'validations' do

    it 'has a valid factory' do
      presenter = FactoryGirl.build(:generic_fields_data_correction, loan: loan_with_generic_info)
      expect(presenter).to be_valid
    end

    it "requires at least one generic field to be entered" do
      presenter = FactoryGirl.build(:generic_fields_data_correction, loan: loan_without_generic_info)
      presenter.generic1 = nil
      presenter.generic2 = nil
      presenter.generic3 = nil
      presenter.generic4 = nil
      presenter.generic5 = nil
      expect(presenter).not_to be_valid
      expect(presenter.errors[:base]).not_to be_empty
    end
  end

  describe '#save' do
    let!(:old_generic_value_1) { loan.generic1 }
    let!(:old_generic_value_2) { loan.generic2 }
    let!(:old_generic_value_3) { loan.generic3 }
    let!(:old_generic_value_4) { loan.generic4 }
    let!(:old_generic_value_5) { loan.generic5 }

    let(:user) { FactoryGirl.create(:lender_user) }

    let!(:presenter) { FactoryGirl.build(:generic_fields_data_correction, loan: loan, created_by: user) }

    context 'success' do
      let!(:loan) { loan_with_generic_info }

      let!(:new_generic_value_1) { "our reference ab12" }
      let!(:new_generic_value_2) { "authorized" }
      let!(:new_generic_value_3) { "important loan info" }
      let!(:new_generic_value_4) { "entered by jeff" }
      let!(:new_generic_value_5) { "loan reference: 12345" }

      it 'creates a DataCorrection and updates the loan' do
        presenter.generic1 = new_generic_value_1
        presenter.generic2 = new_generic_value_2
        presenter.generic3 = new_generic_value_3
        presenter.generic4 = new_generic_value_4
        presenter.generic5 = new_generic_value_5

        expect(presenter.save).to eq(true)

        data_correction = loan.data_corrections.last!
        expect(data_correction.created_by).to eq(user)
        expect(data_correction.change_type).to eq(ChangeType::GenericFields)

        expect(data_correction.old_generic1).to eq(old_generic_value_1)
        expect(data_correction.old_generic2).to eq(old_generic_value_2)
        expect(data_correction.old_generic3).to eq(old_generic_value_3)
        expect(data_correction.old_generic4).to eq(old_generic_value_4)
        expect(data_correction.old_generic5).to eq(old_generic_value_5)

        expect(data_correction.generic1).to eq(new_generic_value_1)
        expect(data_correction.generic2).to eq(new_generic_value_2)
        expect(data_correction.generic3).to eq(new_generic_value_3)
        expect(data_correction.generic4).to eq(new_generic_value_4)
        expect(data_correction.generic5).to eq(new_generic_value_5)

        loan.reload

        expect(loan.generic1).to eq(new_generic_value_1)
        expect(loan.generic2).to eq(new_generic_value_2)
        expect(loan.generic3).to eq(new_generic_value_3)
        expect(loan.generic4).to eq(new_generic_value_4)
        expect(loan.generic5).to eq(new_generic_value_5)
        expect(loan.modified_by).to eq(user)
      end
    end

    context 'failure' do
      let!(:loan) { loan_without_generic_info }

      it 'does not update loan' do
        presenter.generic1 = nil
        presenter.generic2 = nil
        presenter.generic3 = nil
        presenter.generic4 = nil
        presenter.generic5 = nil

        expect(presenter.save).to eq(false)
        loan.reload

        expect(loan.generic1).to eq(old_generic_value_1)
        expect(loan.generic2).to eq(old_generic_value_2)
        expect(loan.generic3).to eq(old_generic_value_3)
        expect(loan.generic4).to eq(old_generic_value_4)
        expect(loan.generic5).to eq(old_generic_value_5)
      end
    end

  end

end
