class Phase6StateAidLetter < StateAidLetter

  private

  def build
    letterhead
    applicant_details
    title(:title)
    loan_details
    body_text(:body_text1)
    state_aid_amount
    body_text(:body_text2, margin: 80)
    title(:annex_title)
    body_text(:annex_text1)
    annex_table
    body_text(:annex_text2)
    indented_text(:annex_text3)
    indented_text(:annex_text4)
    body_text(:annex_text5)
  end

  def loan_details
    data = [
      ["Applicant:", @loan.business_name],
      ["Lender:", @loan.lender.name],
      ["EFG Facility Reference Number:", @loan.reference],
      ["Facility Amount:", @loan.amount.format],
      ["Guarantee Term:", "#{@loan.repayment_duration.total_months} months"],
    ]

    table(data) do
      cells.borders = []
      columns(0).font_style = :bold
    end

    move_down 20
  end

  def annex_table
    data = [
      [ 'Sector', 'Maximum Permissible Aid (€)', 'Relevant Regulation', 'Regulation Date' ],
      [ 'Agriculture', '15,000', '1408/2013', '18/12/13' ],
      [ 'Fisheries and Aquaculture', '30,000', '875/2007', '24/7/07' ],
      [ 'Road Transport', '100,000', '1407/2013', '18/12/13' ],
      [ 'All Other Eligible Sectors', '200,000', '1407/2013', '18/12/13' ],
    ]

    table(data, header: true, cell_style: { size: 12, align: :center }) do
      row(0).font_style = :bold
      column(0).align = :left
    end

    move_down 20
  end

  def translation_scope
    'pdfs.phase6_state_aid_letter'
  end

end
