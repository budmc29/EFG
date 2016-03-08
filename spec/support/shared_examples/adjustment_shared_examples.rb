shared_examples_for "adjustment" do

  describe 'validations' do
    let(:adjustment) { FactoryGirl.build(described_class.to_s.underscore) }

    it 'has a valid factory' do
      expect(adjustment).to be_valid
    end

    it 'strictly requires an amount' do
      expect {
        adjustment.amount = ''
        adjustment.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end

    it 'strictly requires a creator' do
      expect {
        adjustment.created_by = nil
        adjustment.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end

    it 'strictly requires a date' do
      expect {
        adjustment.date = ''
        adjustment.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end

    it 'strictly requires a loan' do
      expect {
        adjustment.loan = nil
        adjustment.valid?
      }.to raise_error(ActiveModel::StrictValidationFailed)
    end
  end

end
