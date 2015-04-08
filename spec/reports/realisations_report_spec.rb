require 'spec_helper'

describe RealisationsReport do
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

  let(:report) {
    RealisationsReport.new(2.days.ago, Date.today, [lender1.id, lender2.id, lender3.id, lender4.id])
  }

  describe '#report_realisations' do
    subject(:report_realisations) { report.realisations }

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
