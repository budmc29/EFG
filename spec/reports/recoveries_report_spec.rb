require 'rails_helper'

describe RecoveriesReport do
  describe 'validations' do
    let(:end_date) { Date.today }
    let(:report_options) {
      {
        'end_date' => end_date,
        'start_date' => start_date
      }
    }
    let(:start_date) { 2.days.ago }
    let(:user) { FactoryGirl.build(:cfe_user) }

    subject(:report) { RecoveriesReport.new(user, report_options) }

    context 'with empty options' do
      let(:report_options) { {} }
      it { should be_invalid }
    end

    context 'with blank start_date' do
      let(:start_date) { '' }
      it { should be_invalid }
    end

    context 'with blank end_date' do
      let(:end_date) { '' }
      it { should be_invalid }
    end

    context 'with end_date before start_date' do
      let(:start_date) { Date.today }
      let(:end_date) { 3.days.ago }
      it { should be_invalid }
    end

    context 'as a user with many lenders' do
      let(:lender1) { FactoryGirl.create(:lender) }
      let(:lender2) { FactoryGirl.create(:lender) }
      let(:lender_ids) { [lender1.id, lender2.id] }
      let(:user) { FactoryGirl.create(:cfe_user) }
      let(:report_options) {
        {
          'end_date' => end_date,
          'lender_ids' => lender_ids,
          'start_date' => start_date
        }
      }

      context 'with valid options' do
        it { should be_valid }
      end

      context 'with nil lender_ids' do
        let(:lender_ids) { nil }
        it { should be_invalid }
      end

      context 'with empty lender_ids' do
        let(:lender_ids) { [] }
        it { should be_invalid }
      end

      context 'with Rails blank string lender_ids' do
        let(:lender_ids) { [''] }
        it { should be_invalid }
      end
    end

    context 'as a user with one lender' do
      let(:user) { FactoryGirl.create(:lender_user) }

      context 'with empty lender_ids' do
        let(:lender_ids) { nil }
        it { should be_valid }
      end
    end
  end

  describe '#recoveries' do
    let(:loan1) { FactoryGirl.create(:loan, :settled, lender: lender1, reference: 'abc', settled_on: 1.week.ago) }
    let(:loan2) { FactoryGirl.create(:loan, :settled, lender: lender2, reference: 'lmn', settled_on: 1.week.ago) }
    let(:loan3) { FactoryGirl.create(:loan, :settled, lender: lender3, reference: 'xyz', settled_on: 1.week.ago) }
    let(:lender1) { FactoryGirl.create(:lender, name: 'Lender1') }
    let(:lender2) { FactoryGirl.create(:lender, name: 'Lender2') }
    let(:lender3) { FactoryGirl.create(:lender, name: 'Lender3') }
    let(:lending_limit2) { FactoryGirl.create(:lending_limit, lender: lender2, phase_id: 4) }
    let(:lending_limit3) { FactoryGirl.create(:lending_limit, lender: lender3, phase_id: 5) }
    let(:recoveries) { report.recoveries.to_a }
    let(:report) { RecoveriesReport.new(user, report_options) }

    let!(:recovery1) { FactoryGirl.create(:recovery, :realised,   loan: loan1, recovered_on: 4.days.ago) }
    let!(:recovery2) { FactoryGirl.create(:recovery, :unrealised, loan: loan2, recovered_on: 3.days.ago) }
    let!(:recovery3) { FactoryGirl.create(:recovery, :realised,   loan: loan3, recovered_on: 2.days.ago) }
    let!(:recovery4) { FactoryGirl.create(:recovery, :unrealised, loan: loan3, recovered_on: 1.day.ago) }

    context 'as a cfe_user' do
      let(:report_options) {
        {
          lender_ids: [lender2.id, lender3.id],
          start_date: 3.days.ago,
          end_date: 2.days.ago
        }
      }
      let(:user) { FactoryGirl.create(:cfe_user) }

      it do
        expect(recoveries.size).to eql(2)

        first = recoveries[0]
        second = recoveries[1]

        expect(first.lender_name).to eql('Lender2')
        expect(first.loan_reference).to eql('lmn')
        expect(first.realise_flag).to be_falsey
        expect(first.recovered_on).to eql(3.day.ago.to_date)

        expect(second.lender_name).to eql('Lender3')
        expect(second.loan_reference).to eql('xyz')
        expect(second.realise_flag).to be_truthy
        expect(second.recovered_on).to eql(2.day.ago.to_date)
      end
    end

    context 'as a lender_user' do
      let(:report_options) {
        {
          start_date: 3.days.ago,
          end_date: 2.days.ago
        }
      }
      let(:user) { FactoryGirl.create(:lender_user, lender: lender3) }

      it do
        expect(recoveries.size).to eql(1)

        first = recoveries[0]

        expect(first.lender_name).to eql('Lender3')
        expect(first.loan_reference).to eql('xyz')
        expect(first.realise_flag).to be_truthy
        expect(first.recovered_on).to eql(2.day.ago.to_date)
      end
    end
  end
end
