require 'spec_helper'

describe RecoveriesReport do
  let!(:recovery1) { FactoryGirl.create(:recovery, :realised, recovered_on: 1.day.ago.to_date) }
  let!(:recovery2) { FactoryGirl.create(:recovery, :realised, recovered_on: 4.day.ago.to_date) }
  let!(:recovery3) { FactoryGirl.create(:recovery, :unrealised, recovered_on: 1.day.ago.to_date) }
  let!(:recovery4) { FactoryGirl.create(:recovery, :realised, recovered_on: 3.day.ago.to_date) }
  let!(:recovery5) { FactoryGirl.create(:recovery, :unrealised, recovered_on: 1.day.ago.to_date) }

  let(:lender1) { recovery1.loan.lender }
  let(:lender2) { recovery2.loan.lender }
  let(:lender3) { recovery3.loan.lender }
  let(:lender4) { recovery4.loan.lender }
  let(:lender5) { recovery5.loan.lender }

  let(:report) { RecoveriesReport.new(2.days.ago.to_date, Date.today, [lender1.id, lender2.id, lender3.id, lender4.id]) }

  describe '#report_recoveries' do
    subject(:report_recoveries) { report.recoveries }

    its(:size) { should == 2 }

    describe 'the first record' do
      subject { report_recoveries.first }

      its(:loan_reference) { should == recovery1.loan.reference }
      its(:amount_due_to_dti) { should == recovery1.amount_due_to_dti }
      its(:recovered_on) { should == 1.day.ago.to_date }
      its(:lender_name) { should == lender1.name }
      its(:realised) { should == 1 }
    end

    describe 'the last record' do
      subject { report_recoveries.last }

      its(:loan_reference) { should == recovery3.loan.reference }
      its(:amount_due_to_dti) { should == recovery3.amount_due_to_dti }
      its(:recovered_on) { should == 1.day.ago.to_date }
      its(:lender_name) { should == lender3.name }
      its(:realised) { should == 0 }
    end
  end

end
