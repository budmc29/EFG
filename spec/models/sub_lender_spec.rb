require 'rails_helper'

describe SubLender do

  describe 'validations' do
    let(:sub_lender) { FactoryGirl.build(:sub_lender) }

    it 'has a valid Factory' do
      expect(sub_lender).to be_valid
    end

    it 'strictly requires a lender' do
      expect {
        sub_lender.lender = nil
        sub_lender.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end

    it 'requires a name' do
      sub_lender.name = ''
      expect(sub_lender).not_to be_valid
    end
  end

end
