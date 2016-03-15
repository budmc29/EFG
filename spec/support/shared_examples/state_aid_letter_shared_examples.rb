shared_examples_for "State Aid Letter PDF" do
  describe "#render" do
    it "contains applicant details and letter date when provided" do
      pdf_content = render_pdf_content(
        pdf_opts: {
          applicant_name: "Mr Borrower",
          applicant_address1: "Borrower's Street",
          applicant_address2: "Borrower's Borough",
          applicant_address3: "Borrower's Town",
          applicant_address4: "Borrower's County",
          applicant_postcode: "AB1 2CD",
          letter_date: "26/03/2016",
        }
      )

      expect(pdf_content).to include("Mr Borrower")
      expect(pdf_content).to include("Borrower's Street")
      expect(pdf_content).to include("Borrower's Borough")
      expect(pdf_content).to include("Borrower's Town")
      expect(pdf_content).to include("Borrower's County")
      expect(pdf_content).to include("AB1 2CD")
      expect(pdf_content).to include("26/03/2016")
    end

    it "contains address fields" do
      pdf_content = render_pdf_content

      expect(pdf_content).to include("Name")
      expect(pdf_content).to include("Address")
      expect(pdf_content).to include("Date")
    end

    it "contain a title" do
      pdf_content = render_pdf_content

      expect(pdf_content).to include(I18n.t("pdfs.state_aid_letter.title").upcase)
    end

    it "contains loan details" do
      loan = FactoryGirl.create(
        :loan,
        :completed,
        :guaranteed,
        business_name: "ACME",
        reference: "ABC123",
        amount: Money.new(10_000_00),
        repayment_duration: 24, 
      )
      allow(loan.lender).to receive(:name).and_return("Big Bank")

      pdf_content = render_pdf_content(loan: loan)

      expect(pdf_content).to include("ACME")
      expect(pdf_content).to include("Big Bank")
      expect(pdf_content).to include("ABC123")
      expect(pdf_content).to include("£10,000.00")
      expect(pdf_content).to include("24")
    end

    it "contains state aid calculation" do
      loan = FactoryGirl.create(
        :loan,
        state_aid: Money.new(15_349_00),
      )
      pdf_content = render_pdf_content(loan: loan)

      expect(pdf_content).to include(
        I18n.t(
          "pdfs.state_aid_letter.state_aid",
          amount: "€15,349.00"
        )
      )
    end
  end
end
