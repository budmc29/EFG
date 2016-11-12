class AmendCompletedLoan
  attr_accessor :modified_by
  attr_reader :new_loan, :loan

  delegate :reference, to: :loan

  def initialize(loan)
    @loan = loan
    unless loan.state == Loan::Completed
      raise IncorrectLoanStateError.new("Only completed Loans can be amended")
    end
  end

  def new_reference
    LoanReference.increment(loan.reference)
  end

  def save!
    loan.transaction do
      @new_loan = loan.dup
      @new_loan.legacy_id = nil
      @new_loan.reference = LoanReference.increment(loan.reference)
      @new_loan.state = Loan::Incomplete
      @new_loan.modified_by = modified_by
      @new_loan.save!

      loan_cancel = LoanCancel.new(loan)
      loan_cancel.modified_by = modified_by
      loan_cancel.cancelled_on = Date.current.to_s(:screen)
      loan_cancel.cancelled_reason_id = CancelReason::Other.id
      loan_cancel.cancelled_comment = "This was a completed loan that was
      amended and replaced by loan #{@new_loan.reference}"

      unless loan_cancel.save
        raise AmendCompletedLoanError.new(
          "Failed to cancel loan #{loan.reference}"
        )
      end

      LoanStateChange.log(
        new_loan, LoanEvent::AmendCompletedLoan, modified_by
      )
    end
  end
end

class AmendCompletedLoanError < StandardError; end
