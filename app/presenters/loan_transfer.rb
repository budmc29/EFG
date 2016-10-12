class LoanTransfer
  include LoanPresenter

  ALLOWED_LOAN_TRANSFER_STATES = [
    Loan::Guaranteed,
    Loan::Demanded,
    Loan::Repaid,
  ].freeze

  attr_reader :loan_to_transfer, :new_loan

  attr_accessor :new_amount, :lender

  attribute :amount
  attribute :facility_letter_date
  attribute :reference
  attribute :declaration_signed

  attr_accessible :new_amount

  validates_presence_of :amount, :new_amount, :reference, :lender,
                        :facility_letter_date

  validate do
    errors.add(:declaration_signed, :accepted) unless declaration_signed
  end

  def new_amount=(value)
    @new_amount = value.present? ? Money.parse(value) : nil
  end

  def loan_to_transfer
    @loan_to_transfer ||= Loan.where(
      reference: reference,
      amount: amount.cents,
      facility_letter_date: facility_letter_date,
      state: ALLOWED_LOAN_TRANSFER_STATES
    ).first
  end

  def save
    return false unless valid? && loan_can_be_transferred?

    Loan.transaction do
      loan_to_transfer.modified_by = modified_by
      loan_to_transfer.state = Loan::RepaidFromTransfer
      loan_to_transfer.save!

      @new_loan                      = loan_to_transfer.dup
      new_loan.lender                = lender
      new_loan.amount                = new_amount
      new_loan.reference             = new_loan_reference
      new_loan.state                 = Loan::Incomplete
      new_loan.repayment_duration    = 0
      new_loan.transferred_from_id   = loan_to_transfer.id
      new_loan.lending_limit         = lender.lending_limits.active.first
      new_loan.created_by            = modified_by
      new_loan.modified_by           = modified_by
      new_loan.loan_security_types   =
        loan_to_transfer.loan_security_types.map(&:id)

      %w(
        legacy_id
        sortcode
        repayment_frequency_id
        maturity_date
        invoice_id
        lender_reference
        sub_lender
      ).each do |field|
        new_loan.public_send("#{field}=", nil)
      end

      (1..5).each do |num|
        new_loan.public_send("generic#{num}=", nil)
      end

      yield new_loan if block_given?

      new_loan.save!
      log_loan_state_changes!
    end

    true
  end

  private

  def loan_can_be_transferred?
    unless loan_to_transfer.is_a?(Loan)
      errors.add(:base, :cannot_be_transferred)
      return false
    end

    if loan_to_transfer.efg_loan?
      errors.add(:base, :cannot_be_transferred)
    end

    unless lender.can_access_all_loan_schemes?
      errors.add(:base, :cannot_be_transferred)
    end

    if new_amount > loan_to_transfer.amount
      errors.add(:new_amount, :cannot_be_greater)
    end

    unless ALLOWED_LOAN_TRANSFER_STATES.include?(loan_to_transfer.state)
      errors.add(:base, :cannot_be_transferred)
    end

    if loan_to_transfer.already_transferred?
      errors.add(:base, :cannot_be_transferred)
    end

    if loan_to_transfer.lender == lender
      errors.add(:base, :cannot_transfer_own_loan)
    end

    errors.empty?
  end

  def log_loan_state_changes!
    [loan_to_transfer, new_loan].each do |loan|
      LoanStateChange.log(loan, LoanEvent::Transfer, loan.modified_by)
    end
  end

  def new_loan_reference
    LoanReference.increment(loan_to_transfer.reference)
  end
end
