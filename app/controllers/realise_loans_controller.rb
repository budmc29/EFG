class RealiseLoansController < ApplicationController

  before_filter :verify_create_permission, only: [:new, :select_loans, :create]

  def show
    enforce_view_permission(RealisationStatement)
    realisation_statement = RealisationStatement.find(params[:id])
    @loan_realisations = realisation_statement.loan_realisations.includes(:realised_loan)
  end

  def new
    @realisation_statement = RealisationStatementReceived.new
  end

  def select_loans
    @realisation_statement = RealisationStatementReceived.new(params[:realisation_statement_received])

    if @realisation_statement.invalid?(:details)
      render :new and return
    end

    respond_to do |format|
      format.html
      format.csv do
        filename = "loan_recoveries_#{@realisation_statement.lender.name.parameterize}_#{Date.current.to_s(:db)}.csv"
        csv_export = LoanRecoveriesCsvExport.new(@realisation_statement.recoveries)
        stream_response(csv_export, filename)
      end
    end
  end

  def create
    @realisation_statement = RealisationStatementReceived.new(params[:realisation_statement_received])
    @realisation_statement.creator = current_user

    if @realisation_statement.save
      redirect_to realise_loan_url(@realisation_statement.realisation_statement)
    else
      render :select_loans
    end
  end

  private

  def verify_create_permission
    enforce_create_permission(RealisationStatement)
  end

end
