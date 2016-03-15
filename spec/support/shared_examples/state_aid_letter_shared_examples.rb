shared_examples_for 'State Aid Letter PDF' do
  describe "#render" do

    it "should contain address fields" do
      expect(pdf_content).to include('Name')
      expect(pdf_content).to include('Address')
      expect(pdf_content).to include('Date')
    end

    it "should contain a title" do
      expect(pdf_content).to include(I18n.t('pdfs.state_aid_letter.title').upcase)
    end

    it "should contain loan details" do
      expect(pdf_content).to include(loan.business_name)
      expect(pdf_content).to include(loan.lender.name)
      expect(pdf_content).to include(loan.reference)
      expect(pdf_content).to include(loan.amount.format)
      expect(pdf_content).to include(loan.repayment_duration.total_months.to_s)
    end

    it "should contain state aid calculation" do
      expect(pdf_content).to include(I18n.t('pdfs.state_aid_letter.state_aid', amount: loan.state_aid.format))
    end

  end
end
