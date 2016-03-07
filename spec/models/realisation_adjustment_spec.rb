require 'rails_helper'

describe RealisationAdjustment do
  describe 'validations' do
    let(:realisation_adjustment) { FactoryGirl.build(:realisation_adjustment) }

    it 'has a valid factory' do
      expect(realisation_adjustment).to be_valid
    end

    it 'strictly requires an amount' do
      expect {
        realisation_adjustment.amount = ''
        realisation_adjustment.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end

    it 'strictly requires a creator' do
      expect {
        realisation_adjustment.created_by = nil
        realisation_adjustment.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end

    it 'strictly requires a date' do
      expect {
        realisation_adjustment.date = ''
        realisation_adjustment.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end

    it 'strictly requires a loan' do
      expect {
        realisation_adjustment.loan = nil
        realisation_adjustment.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end
  end
end
