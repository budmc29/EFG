shared_examples_for 'a basic data correction' do |attribute, input_value, new_value = nil|
  include DataCorrectionSpecHelper

  let(:loan) { FactoryGirl.create(:loan, :guaranteed, legal_form_id: 4, lender: current_user.lender) }
  let!(:old_value) { loan.public_send(attribute) }
  let(:expected_new_value) { new_value || input_value }

  before do
    visit_data_corrections
    click_link attribute.to_s.titleize
  end

  it do
    fill_in attribute, input_value
    click_button 'Submit'

    data_correction = loan.data_corrections.last!
    expect(data_correction.change_type).to eq("ChangeType::#{attribute.to_s.classify}".constantize)
    expect(data_correction.created_by).to eq(current_user)
    expect(data_correction.date_of_change).to eq(Date.current)
    expect(data_correction.modified_date).to eq(Date.current)
    expect(data_correction.public_send("old_#{attribute}")).to eq(old_value)
    expect(data_correction.public_send(attribute)).to eq(expected_new_value)

    loan.reload
    expect(loan.public_send(attribute)).to eq(expected_new_value)
    expect(loan.modified_by).to eq(current_user)
  end

  it 'with no input' do
    click_button 'Submit'

    loan.reload
    expect(loan.modified_by).not_to eql(current_user)
  end
end

shared_examples_for 'a basic data correction presenter' do |attribute, input_value, new_value = nil, loan_attrs = {}|
  let(:factory_name) { "#{attribute}_data_correction" }
  let(:user) { FactoryGirl.create(:lender_user) }
  let(:loan) { FactoryGirl.create(:loan, :guaranteed, loan_attrs) }
  let(:presenter) { FactoryGirl.build(factory_name, created_by: user, loan: loan) }
  let(:expected_new_value) { new_value || input_value }

  describe 'validations' do
    let(:presenter) { FactoryGirl.build(factory_name, loan: loan) }

    it 'has a valid factory' do
      expect(presenter).to be_valid
    end

    it "requires a #{attribute}" do
      presenter.public_send("#{attribute}=", '')
      expect(presenter).not_to be_valid
    end

    it "new #{attribute} value must not be the same as old value" do
      presenter.public_send("#{attribute}=", loan.public_send(attribute))
      expect(presenter).not_to be_valid
    end
  end

  it_behaves_like "loan updating data correction presenter", attribute, input_value, new_value, loan_attrs

end

shared_examples_for "loan updating data correction presenter" do |attribute, input_value, new_value = nil, loan_attrs = {}|
  let(:factory_name) { "#{attribute}_data_correction" }
  let(:user) { FactoryGirl.create(:lender_user) }
  let(:loan) { FactoryGirl.create(:loan, :guaranteed, loan_attrs) }
  let(:presenter) { FactoryGirl.build(factory_name, created_by: user, loan: loan) }
  let(:expected_new_value) { new_value || input_value }

  describe '#save' do
    let!(:old_value) { loan.public_send(attribute) }

    context 'success' do
      it 'creates a DataCorrection and updates the loan' do
        presenter.public_send("#{attribute}=", input_value)
        expect(presenter.save).to eq(true)

        data_correction = loan.data_corrections.last!
        expect(data_correction.created_by).to eq(user)
        expect(data_correction.change_type).to eq("ChangeType::#{attribute.to_s.classify}".constantize)
        expect(data_correction.public_send("old_#{attribute}")).to eq(old_value)
        expect(data_correction.public_send(attribute)).to eq(expected_new_value)

        loan.reload
        expect(loan.public_send(attribute)).to eq(expected_new_value)
        expect(loan.modified_by).to eq(user)
      end
    end

    context 'failure' do
      it 'does not update loan' do
        presenter.public_send("#{attribute}=", nil)
        expect(presenter.save).to eq(false)
        loan.reload

        expect(loan.public_send(attribute)).to eq(old_value)
      end
    end
  end
end
