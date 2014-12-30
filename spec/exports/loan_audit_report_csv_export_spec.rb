require 'spec_helper'
require 'csv'

describe LoanAuditReportCsvExport do
  describe ".header" do
    let(:loan_audit_report_csv_export) { LoanAuditReportCsvExport.new(Loan.all) }

    let(:header) { CSV.parse(loan_audit_report_csv_export.first).first }

    it "should return array of strings with correct text" do
      header[0].should == t(:loan_reference)
      header[1].should == t(:lender_id)
      header[2].should == t(:facility_amount)
      header[3].should == t(:maturity_date)
      header[4].should == t(:cancellation_date)
      header[5].should == t(:scheme_facility_letter_date)
      header[6].should == t(:initial_draw_date)
      header[7].should == t(:lender_demand_date)
      header[8].should == t(:repaid_date)
      header[9].should == t(:no_claim_date)
      header[10].should == t(:government_demand_date)
      header[11].should == t(:settled_date)
      header[12].should == t(:guarantee_remove_date)
      header[13].should == t(:generic1)
      header[14].should == t(:generic2)
      header[15].should == t(:generic3)
      header[16].should == t(:generic4)
      header[17].should == t(:generic5)
      header[18].should == t(:loan_reason)
      header[19].should == t(:loan_category)
      header[20].should == t(:loan_sub_category)
      header[21].should == t(:loan_state)
      header[22].should == t(:created_at)
      header[23].should == t(:created_by)
      header[24].should == t(:modified_date)
      header[25].should == t(:modified_by)
      header[26].should == t(:audit_record_sequence)
      header[27].should == t(:from_state)
      header[28].should == t(:to_state)
      header[29].should == t(:loan_function)
      header[30].should == t(:audit_record_modified_date)
      header[31].should == t(:audit_record_modified_by)
    end
  end

  describe "#generate" do

    let!(:loan) { FactoryGirl.create(:loan) }

    let(:loan_audit_report_mock) { double(LoanAuditReportCsvRow, to_a: row_mock) }

    let(:loan_audit_report_csv_export) { LoanAuditReportCsvExport.new(Loan.all) }

    let(:row_mock) { Array.new(loan_audit_report_csv_export.fields.size) }

    let(:parsed_csv) { CSV.parse(loan_audit_report_csv_export.generate) }

    before(:each) do
      loan_audit_report_csv_export.stub(:csv_row).and_return(loan_audit_report_mock)
      Loan.any_instance.stub(:loan_state_change_to_state).and_return(Loan::Guaranteed)
    end

    it "should return a row for the header and each loan" do
      parsed_csv.size.should == 2
    end
  end

  private

  def t(key)
    I18n.t(key, scope: 'csv_headers.loan_audit_report')
  end

end
