require 'spec_helper'

describe 'Generic Fields Data Correction' do

  include DataCorrectionSpecHelper

  let(:loan) { FactoryGirl.create(:loan, :guaranteed, lender: current_user.lender) }
  let!(:old_generic_value_1) { loan.generic1 }
  let!(:old_generic_value_2) { loan.generic2 }
  let!(:old_generic_value_3) { loan.generic3 }
  let!(:old_generic_value_4) { loan.generic4 }
  let!(:old_generic_value_5) { loan.generic5 }

  let!(:new_generic_value_1) { "our reference ab12" }
  let!(:new_generic_value_2) { "authorized" }
  let!(:new_generic_value_3) { "important loan info" }
  let!(:new_generic_value_4) { "entered by jeff" }
  let!(:new_generic_value_5) { "" }

  before do
    visit_data_corrections
    click_link "Generic Fields"
  end

  it do
    fill_in :generic1, new_generic_value_1
    fill_in :generic2, new_generic_value_2
    fill_in :generic3, new_generic_value_3
    fill_in :generic4, new_generic_value_4
    fill_in :generic5, new_generic_value_5

    click_button 'Submit'

    data_correction = loan.data_corrections.last!
    expect(data_correction.change_type).to eq(ChangeType::GenericFields)
    expect(data_correction.created_by).to eq(current_user)
    expect(data_correction.date_of_change).to eq(Date.current)
    expect(data_correction.modified_date).to eq(Date.current)

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
    expect(loan.modified_by).to eq(current_user)
  end

end
