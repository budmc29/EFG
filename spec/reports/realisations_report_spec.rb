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

  describe 'with valid options' do
    let!(:realisation1) { FactoryGirl.create(:loan_realisation, :pre,
                                                  realised_amount: Money.new(1_000_00),
                                                  realised_on: 1.day.ago) }
    let!(:realisation2) { FactoryGirl.create(:loan_realisation, :post,
                                                  realised_amount: Money.new(2_000_00),
                                                  realised_on: 4.day.ago) }
    let!(:realisation3) { FactoryGirl.create(:loan_realisation, :post,
                                                  realised_amount: Money.new(3_000_00),
                                                  realised_on: 1.day.ago) }
    let!(:realisation4) { FactoryGirl.create(:loan_realisation, :post,
                                                  realised_amount: Money.new(4_000_00),
                                                  realised_on: 3.day.ago) }
    let!(:realisation5) { FactoryGirl.create(:loan_realisation, :pre,
                                                  realised_amount: Money.new(4_000_00),
                                                  realised_on: 1.day.ago) }

    let(:lender1) { realisation1.realised_loan.lender }
    let(:lender2) { realisation2.realised_loan.lender }
    let(:lender3) { realisation3.realised_loan.lender }
    let(:lender4) { realisation4.realised_loan.lender }
    let(:lender5) { realisation5.realised_loan.lender }

    let(:report_options) {
      {
        lender_ids: [lender1.id, lender2.id, lender3.id, lender4.id],
        start_date: 2.days.ago,
        end_date: Date.today
      }
    }

    context 'when user is cfe_user' do
      let(:user) { FactoryGirl.create(:cfe_user) }
      subject(:report) { RealisationsReport.new(user, report_options) }

      its(:allowed_lenders) {
        should match_array(user.lenders << RealisationsReport::ALL_LENDERS_OPTION)
      }

      its(:lender_ids) { should match_array([lender1.id, lender2.id, lender3.id, lender4.id]) }
      its(:size) { should == 2 }

      describe '#realisations' do
        subject(:realisations) { report.realisations }

        its(:size) { should == 2 }

        describe 'the first record' do
          subject { realisations.first }

          its(:loan_reference) { should == realisation1.realised_loan.reference }
          its(:realised_on) { should == 1.day.ago.to_date }
          its(:lender_name) { should == lender1.name }
          its(:realised_amount) { should == realisation1.realised_amount }
          its(:post_claim_limit) { should == realisation1.post_claim_limit }
        end

        describe 'the last record' do
          subject { realisations.last }

          its(:loan_reference) { should == realisation3.realised_loan.reference }
          its(:realised_on) { should == 1.day.ago.to_date }
          its(:lender_name) { should == lender3.name }
          its(:realised_amount) { should == realisation3.realised_amount }
          its(:post_claim_limit) { should == realisation3.post_claim_limit }
        end
      end
    end

    context 'when user is lender_user' do
      let(:user) { FactoryGirl.create(:lender_user, lender: lender1) }
      subject(:report) { RealisationsReport.new(user, report_options) }

      its(:lender_ids) { should match_array([user.lender_id]) }
      its(:size) { should == 1 }

      describe '#realisations' do
        subject(:realisations) { report.realisations }

        its(:size) { should == 1 }

        describe 'the only record' do
          subject { realisations.first }

          its(:loan_reference) { should == realisation1.realised_loan.reference }
          its(:realised_on) { should == 1.day.ago.to_date }
          its(:lender_name) { should == lender1.name }
          its(:realised_amount) { should == realisation1.realised_amount }
          its(:post_claim_limit) { should == realisation1.post_claim_limit }
        end
      end
    end
  end
end
