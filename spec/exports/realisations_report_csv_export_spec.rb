require 'spec_helper'
require 'csv'

describe RealisationsReportCsvExport do
  let!(:realisation1) { FactoryGirl.create(:loan_realisation, realised_on: 1.day.ago.to_date) }
  let!(:realisation2) { FactoryGirl.create(:loan_realisation, realised_on: 2.day.ago.to_date) }
  let(:loan1) { realisation1.realised_loan }
  let(:loan2) { realisation2.realised_loan }
  let(:lender1) { realisation1.realised_loan.lender }
  let(:lender2) { realisation2.realised_loan.lender }
  let(:report_realisations) { RealisationsReport.new(3.days.ago.to_date, Date.today, Lender.all).realisations }

  subject(:export) { RealisationsReportCsvExport.new(report_realisations) }

  its(:fields) { should == [
      :lender_name,
      :loan_reference,
      :realised_on,
      :realised_amount,
      :post_claim_limit
    ]
  }

  its(:generate) { should == %Q[Lender Name,Loan Reference,Realised On,Realised Amount,Post Claim Limit?
#{lender1.name},#{loan1.reference},#{realisation1.realised_on},#{realisation1.realised_amount},#{realisation1.post_claim_limit}
#{lender2.name},#{loan2.reference},#{realisation2.realised_on},#{realisation2.realised_amount},#{realisation2.post_claim_limit}
] }

end