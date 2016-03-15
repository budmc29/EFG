class StateAidLetter < Prawn::Document
  class Address
    NUMBER_OF_ADDRESS_FIELDS = 5
    LINE_HEIGHT = BOTTOM_SPACING = 20

    def initialize(pdf, opts = {})
      @pdf = pdf
      @opts = opts
    end

    def render
      if has_address?
        populated_address_fields.map { |f| pdf.text(f) }
      else
        pdf.text "<b>Applicant Address:</b>", inline_format: true
      end
      pdf.move_down(bottom_spacing_height)
    end

    private

    attr_reader :pdf, :opts

    def populated_address_fields
      @populated_address_fields ||= %i(
        applicant_address1
        applicant_address2
        applicant_address3
        applicant_address4
        applicant_postcode
      ).map { |attr| opts[attr] }.reject(&:blank?)
    end

    def populated_address_height
      populated_address_fields.size * LINE_HEIGHT
    end

    def has_address?
      populated_address_fields.present?
    end

    def bottom_spacing_height
      total_height - populated_address_height
    end

    def total_height
      (LINE_HEIGHT * NUMBER_OF_ADDRESS_FIELDS) + BOTTOM_SPACING
    end
  end

  def initialize(loan, pdf_opts = {})
    super(pdf_opts)
    @loan = loan
    @name = pdf_opts.delete(:applicant_name)
    @address = Address.new(self, pdf_opts)
    @date = pdf_opts.delete(:letter_date)
    @filename = "state_aid_letter_#{loan.reference}.pdf"
    self.font_size = 12
    build
  end

  attr_reader :filename

  private

  attr_reader :name, :address, :date

  def build
    letterhead
    applicant_details
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

  def applicant_details
    text applicant_name, inline_format: true
    address.render
    text "<b>Date:</b> #{date}", inline_format: true
    move_down 40
  end
  
  def applicant_name
    name.present? ? name : "<b>Applicant Name:</b>"
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
