class LoanStatusAmendment
  include LoanPresenter

  ELIGIBILITY = "Eligibility".freeze
  ADMINISTRATIVE = "Administrative".freeze
  LIABILITY = "Liability".freeze
  OTHER = "Other".freeze

  STATUS_AMENDMEND_TYPES = [
    ELIGIBILITY,
    ADMINISTRATIVE,
    LIABILITY,
    OTHER,
  ].freeze

  DISALLOWED_LOAN_STATES = [
    Loan::Rejected,
    Loan::Eligible,
    Loan::Cancelled,
    Loan::Incomplete,
    Loan::Completed,
    Loan::Offered,
  ].freeze

  attribute :status_amendment_type
  attribute :status_amendment_notes

  validates_inclusion_of :status_amendment_type,
                         in: :amendment_types,
                         allow_blank: true
  def initialize(loan)
    if DISALLOWED_LOAN_STATES.include?(loan.state)
      raise IncorrectLoanStateError.new("#{self.class.name} tried to " \
        "perform status amendment on Loan:#{loan.id} with state:#{loan.state}")
    end
    super
  end

  def amendment_types
    STATUS_AMENDMEND_TYPES
  end
end
