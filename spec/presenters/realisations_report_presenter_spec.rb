require 'spec_helper'

describe RealisationsReportPresenter do
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

  let(:loan1) { realisation1.realised_loan }
  let(:loan2) { realisation2.realised_loan }
  let(:loan3) { realisation3.realised_loan }
  let(:loan4) { realisation4.realised_loan }
  let(:loan5) { realisation5.realised_loan }

  let(:lender1) { loan1.lender }
  let(:lender2) { loan2.lender }
  let(:lender3) { loan3.lender }
  let(:lender4) { loan4.lender }
  let(:lender5) { loan5.lender }

  let!(:cfe_user) { FactoryGirl.create(:cfe_user) }
  let!(:lender_user) { FactoryGirl.create(:lender_user, lender: lender1) }


  describe 'validations' do
    subject(:report_presenter) { RealisationsReportPresenter.new(cfe_user, report_options) }

    context 'with empty options' do
      let(:report_options) { {} }
      it { should be_invalid }
    end

    context 'with empty lender_ids' do
      let(:report_options) {
        { lender_ids: [],
          start_date: 2.days.ago,
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
          start_date: 2.days.ago,
          end_date: '' }
      }

      it { should be_invalid }
    end

    context 'with end_date before start_date' do
      let(:report_options) {
        { lender_ids: [lender1.id, lender2.id, lender3.id, lender4.id],
          start_date: Date.today,
          end_date: 3.days.ago }
      }

      it { should be_invalid }
    end
  end


  describe 'with valid options' do
    let(:report_options) {
      {
        lender_ids: [lender1.id, lender2.id, lender3.id, lender4.id],
        start_date: 2.days.ago,
        end_date: Date.today
      }
    }

    context 'when user is cfe_user' do
      subject(:report_presenter) { RealisationsReportPresenter.new(cfe_user, report_options) }

      it { should be_valid }

      its(:allowed_lenders) {
        should match_array(cfe_user.lenders << RealisationsReportPresenter::ALL_LENDERS_OPTION)
      }

      its(:lenders) { should match_array([lender1, lender2, lender3, lender4]) }

      its(:lender_ids) { should match_array([lender1.id, lender2.id, lender3.id, lender4.id]) }

      describe '#report_realisations' do
        subject(:report_realisations) { report_presenter.realisations }

        its(:size) { should == 2 }

        describe 'the first record' do
          subject { report_realisations.first }

          its(:loan_reference) { should == realisation1.realised_loan.reference }
          its(:realised_on) { should == 1.day.ago.to_date }
          its(:lender_name) { should == lender1.name }
          its(:realised_amount) { should == realisation1.realised_amount }
          its(:post_claim_limit) { should == realisation1.post_claim_limit }
        end

        describe 'the last record' do
          subject { report_realisations.last }

          its(:loan_reference) { should == realisation3.realised_loan.reference }
          its(:realised_on) { should == 1.day.ago.to_date }
          its(:lender_name) { should == lender3.name }
          its(:realised_amount) { should == realisation3.realised_amount }
          its(:post_claim_limit) { should == realisation3.post_claim_limit }
        end
      end
    end

    context 'when user is lender_user' do
      subject(:report_presenter) { RealisationsReportPresenter.new(lender_user, report_options) }

      it { should be_valid }

      its(:allowed_lenders) { should match_array([lender_user.lender]) }

      its(:lenders) { should match_array([lender_user.lender]) }

      its(:lender_ids) { should match_array([lender_user.lender.id]) }

      describe '#report_realisations' do
        subject(:report_realisations) { report_presenter.realisations }

        its(:size) { should == 1 }

        describe 'the only record' do
          subject { report_realisations.first }

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
