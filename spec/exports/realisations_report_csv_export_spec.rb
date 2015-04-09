require 'spec_helper'
require 'csv'

describe RealisationsReportCsvExport do
  let(:lender1) { FactoryGirl.create(:lender, name: 'Lender1') }
  let(:lender2) { FactoryGirl.create(:lender, name: 'Lender2') }
  let(:loan1) { FactoryGirl.create(:loan, :realised, lender: lender1, reference: 'abc123') }
  let(:loan2) { FactoryGirl.create(:loan, :realised, lender: lender2, reference: 'xyz123') }
  let(:realisations) { report.realisations }
  let(:report) {
    RealisationsReport.new(
      Date.new(2015, 4, 1),
      Date.new(2015, 4, 2),
      Lender.all
    )
  }
  let(:user) { FactoryGirl.create(:cfe_user) }

  let!(:realisation1) { FactoryGirl.create(:loan_realisation, :pre,  realised_amount: Money.new(101_00), realised_loan: loan1, realised_on: Date.new(2015,4,1)) }
  let!(:realisation2) { FactoryGirl.create(:loan_realisation, :post, realised_amount: Money.new(202_99), realised_loan: loan2, realised_on: Date.new(2015,4,2)) }

  subject { RealisationsReportCsvExport.new(realisations) }

  its(:generate) { should == 'Lender Name,Loan Reference,Realised On,Realised Amount,Post Claim Limit?
Lender1,abc123,2015-04-01,101.00,pre
Lender2,xyz123,2015-04-02,202.99,post
' }
end
