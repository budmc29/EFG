require 'spec_helper'

describe RealisationsReport do
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

    subject(:report) { RealisationsReport.new(user, report_options) }

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

  describe '#realisations' do
    let(:loan1) { FactoryGirl.create(:loan, lender: lender1, reference: 'abc') }
    let(:loan2) { FactoryGirl.create(:loan, lender: lender2, reference: 'lmn') }
    let(:loan3) { FactoryGirl.create(:loan, lender: lender3, reference: 'xyz') }
    let(:lender1) { FactoryGirl.create(:lender, name: 'Lender1') }
    let(:lender2) { FactoryGirl.create(:lender, name: 'Lender2') }
    let(:lender3) { FactoryGirl.create(:lender, name: 'Lender3') }
    let(:realisations) { report.realisations.to_a }
    let(:report) { RealisationsReport.new(user, report_options) }

    let!(:realisation1) { FactoryGirl.create(:loan_realisation, :pre,  realised_amount: Money.new(1_000_00), realised_loan: loan1, realised_on: 3.day.ago) }
    let!(:realisation2) { FactoryGirl.create(:loan_realisation, :pre,  realised_amount: Money.new(2_000_00), realised_loan: loan2, realised_on: 2.day.ago) }
    let!(:realisation3) { FactoryGirl.create(:loan_realisation, :post, realised_amount: Money.new(3_000_00), realised_loan: loan3, realised_on: 1.day.ago) }

    context 'when user is cfe_user' do
      let(:report_options) {
        {
          lender_ids: [lender1.id, lender2.id, lender3.id],
          start_date: 2.days.ago,
          end_date: Date.today
        }
      }
      let(:user) { FactoryGirl.create(:cfe_user) }

      it do
        expect(realisations.size).to eql(2)

        first = realisations[0]
        second = realisations[1]

        expect(first.loan_reference).to eql('lmn')
        expect(first.realised_on).to eql(2.day.ago.to_date)
        expect(first.lender_name).to eql('Lender2')
        expect(first.realised_amount).to eql(Money.new(2_000_00))
        expect(first.post_claim_limit).to eql(false)

        expect(second.loan_reference).to eql('xyz')
        expect(second.realised_on).to eql(1.day.ago.to_date)
        expect(second.lender_name).to eql('Lender3')
        expect(second.realised_amount).to eql(Money.new(3_000_00))
        expect(second.post_claim_limit).to eql(true)
      end
    end

    context 'when user is lender_user' do
      let(:report_options) {
        {
          start_date: 2.days.ago,
          end_date: Date.today
        }
      }
      let(:user) { FactoryGirl.create(:lender_user, lender: lender2) }

      it do
        expect(realisations.size).to eql(1)

        first = realisations[0]

        expect(first.loan_reference).to eql('lmn')
        expect(first.realised_on).to eql(2.day.ago.to_date)
        expect(first.lender_name).to eql('Lender2')
        expect(first.realised_amount).to eql(Money.new(2_000_00))
        expect(first.post_claim_limit).to eql(false)
      end
    end
  end
end
