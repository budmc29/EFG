class StateAidLettersController < ApplicationController
  before_action :verify_view_permission
  before_action :find_loan

  def new
    @state_aid_letter_details = StateAidLetterDetails.new
  end

  def create
    @state_aid_letter_details = StateAidLetterDetails.new(
      params[:state_aid_letter_details])
    pdf = state_aid_letter_pdf.new(
      @loan, @state_aid_letter_details.attributes
    )

    send_data(
      pdf.render,
      filename: pdf.filename,
      type: "application/pdf",
      disposition: "inline",
    )
  end

  private

  def state_aid_letter_pdf
    @loan.rules.state_aid_letter
  end

  def verify_view_permission
    enforce_view_permission(StateAidLetter)
  end

  def find_loan
    @loan = current_lender.loans.find(params[:loan_id])
  end
end
