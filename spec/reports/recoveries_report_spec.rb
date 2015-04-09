require 'spec_helper'

describe RecoveriesReport do
  let!(:recovery1) { FactoryGirl.create(:recovery, :realised, recovered_on: 1.day.ago.to_date) }
  let!(:recovery2) { FactoryGirl.create(:recovery, :realised, recovered_on: 4.day.ago.to_date) }
  let!(:recovery3) { FactoryGirl.create(:recovery, :unrealised, recovered_on: 1.day.ago.to_date) }
  let!(:recovery4) { FactoryGirl.create(:recovery, :realised, recovered_on: 3.day.ago.to_date) }
  let!(:recovery5) { FactoryGirl.create(:recovery, :unrealised, recovered_on: 1.day.ago.to_date) }

  let(:loan1) { recovery1.loan }
  let(:loan2) { recovery2.loan }
  let(:loan3) { recovery3.loan }
  let(:loan4) { recovery4.loan }
  let(:loan5) { recovery5.loan }

  let(:lender1) { recovery1.loan.lender }
  let(:lender2) { recovery2.loan.lender }
  let(:lender3) { recovery3.loan.lender }
  let(:lender4) { recovery4.loan.lender }
  let(:lender5) { recovery5.loan.lender }

  let!(:cfe_user) { FactoryGirl.create(:cfe_user) }
  let!(:lender_user) { FactoryGirl.create(:lender_user, lender: lender1) }

  describe 'validations' do
    subject(:report) { RecoveriesReport.new(cfe_user, report_options) }

    context 'with empty options' do
      let(:report_options) { {} }
      it { should be_invalid }
    end

    context 'with empty lender_ids' do
      let(:report_options) {
        { lender_ids: [],
          start_date: 2.days.ago.to_date,
          end_date: Date.today }
      }

      it { should be_invalid }
    end

    context 'with blank start_date' do
      let(:report_options) {
        { lender_ids: [lender1.id, lender2.id, lender3.id, lender4.id],
          start_date: '',
          end_date: Date.today }
      }

      it { should be_invalid }
    end

    context 'with blank end_date' do
      let(:report_options) {
        { lender_ids: [lender1.id, lender2.id, lender3.id, lender4.id],
          start_date: 2.days.ago.to_date,
          end_date: '' }
      }

      it { should be_invalid }
    end

    context 'with end_date before start_date' do
      let(:report_options) {
        { lender_ids: [lender1.id, lender2.id, lender3.id, lender4.id],
          start_date: Date.today,
          end_date: 3.days.ago.to_date }
      }

      it { should be_invalid }
    end
  end

  describe 'with valid options' do
    let(:report_options) {
      {
        lender_ids: [lender1.id, lender2.id, lender3.id, lender4.id],
        start_date: 2.days.ago.to_date,
        end_date: Date.today
      }
    }

    context 'when user is cfe_user' do
      subject(:report) { RecoveriesReport.new(cfe_user, report_options) }

      it { should be_valid }

      its(:allowed_lenders) {
        should match_array(cfe_user.lenders << RecoveriesReport::ALL_LENDERS_OPTION)
      }

      its(:lender_ids) { should match_array([lender1.id, lender2.id, lender3.id, lender4.id]) }

      its(:lender_names) { should match_array([lender1.name, lender2.name, lender3.name, lender4.name]) }

      describe '#report_recoveries' do
        subject(:report_recoveries) { report.recoveries }

        its(:size) { should == 2 }

        describe 'the first record' do
          subject { report_recoveries.first }

          its(:loan_reference) { should == recovery1.loan.reference }
          its(:recovered_on) { should == 1.day.ago.to_date }
          its(:lender_name) { should == lender1.name }
          its(:realised) { should == 1 }
        end

        describe 'the last record' do
          subject { report_recoveries.last }

          its(:loan_reference) { should == recovery3.loan.reference }
          its(:recovered_on) { should == 1.day.ago.to_date }
          its(:lender_name) { should == lender3.name }
          its(:realised) { should == 0 }
        end
      end
    end

    context 'when user is lender_user' do
      subject(:report) { RecoveriesReport.new(lender_user, report_options) }

      it { should be_valid }

      its(:allowed_lenders) { should match_array([lender_user.lender]) }

      its(:lender_ids) { should match_array([lender_user.lender.id]) }

      its(:lender_names) { should match_array([lender_user.lender.name]) }

      describe '#report_recoveries' do
        subject(:report_recoveries) { report.recoveries }

        its(:size) { should == 1 }

        describe 'the only record' do
          subject { report_recoveries.first }

          its(:loan_reference) { should == recovery1.loan.reference }
          its(:recovered_on) { should == 1.day.ago.to_date }
          its(:lender_name) { should == lender1.name }
          its(:realised) { should == 1 }
        end

      end
    end
  end

end