class StateAidLetter < Prawn::Document

  attr_reader :filename

  def initialize(loan, pdf_opts = {})
    super(pdf_opts)
    @loan = loan
    @filename = "state_aid_letter_#{loan.reference}.pdf"
    self.font_size = 12
    build
  end

  private

  def build
    letterhead
    address
    title(:title)
    loan_details
    body_text(:body_text1)
    state_aid_amount
    body_text(:body_text2)
  end

  def letterhead
    logo = @loan.lender.logo

    if logo && logo.exists?
      image logo.path, height: 50
      move_down 40
    else
      move_down 90
    end
  end

  def address
    text "Applicant Name"
    move_down 20
    text "Applicant Address"
    move_down 20
    text "Date"
    move_down 60
  end

  def title(translation_key)
    text I18n.t(translation_key, scope: translation_scope).upcase, size: 15, style: :bold
    move_down 20
  end

  def loan_details
    data = [
      ["Borrower:", @loan.business_name],
      ["Lender:", @loan.lender.name],
      ["Loan Reference Number:", @loan.reference],
      ["Loan Amount:", @loan.amount.format],
      ["Loan Term:", "#{@loan.repayment_duration.total_months} months"],
      ["Anticipated drawdown date:", "tbc"]
    ]

    table(data) do
      cells.borders = []
      columns(0).font_style = :bold
    end

    move_down 20
  end

  def state_aid_amount
    text I18n.t(:state_aid, scope: translation_scope, amount: @loan.state_aid.format)
    move_down 20
  end

  def body_text(translation_key, opts = {})
    bottom_margin = opts.delete(:margin) || 20
    text I18n.t(translation_key, scope: translation_scope), opts
    move_down(bottom_margin)
  end

  def indented_text(translation_key, opts = {})
    bottom_margin = opts.delete(:margin) || 20
    indent_size = opts.delete(:indent) || 20

    indent(indent_size) do
      text I18n.t(translation_key, scope: translation_scope), opts
      move_down(bottom_margin)
    end
  end

  def translation_scope
    'pdfs.state_aid_letter'
  end

end
