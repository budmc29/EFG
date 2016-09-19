class LoanDemandToBorrower
  include LoanPresenter
  include LoanStateTransition

  transition from: Loan::Guaranteed,
             to: Loan::LenderDemand,
             event: LoanEvent::DemandToBorrower

  attribute :amount_demanded
  attribute :borrower_demanded_on
  attribute :borrower_demand_outstanding

  validates_presence_of :amount_demanded,
                        :borrower_demanded_on,
                        :borrower_demand_outstanding

  validate :validate_gte_loan_initial_draw_date, if: :borrower_demanded_on
  validate :borrower_demanded_on_is_not_in_the_future, if: :borrower_demanded_on
  validate :outstanding_amount_is_less_than_demanded_amount

  before_save :set_loan_values
  before_save :build_demand_to_borrower

  private

  def build_demand_to_borrower
    loan.demand_to_borrowers.build do |dtb|
      dtb.created_by = modified_by
      dtb.modified_date = Date.current
      dtb.date_of_demand = borrower_demanded_on
      dtb.demanded_amount = amount_demanded
      dtb.outstanding_facility_amount = borrower_demand_outstanding
    end
  end

  def set_loan_values
    loan.tap do |l|
      l.amount_demanded = amount_demanded
      l.borrower_demanded_on = borrower_demanded_on
      l.borrower_demand_outstanding = borrower_demand_outstanding
    end
  end

  def validate_gte_loan_initial_draw_date
    if borrower_demanded_on < loan.initial_draw_date
      errors.add(:borrower_demanded_on, :must_be_after_loan_initial_draw_date)
    end
  end

  def borrower_demanded_on_is_not_in_the_future
    if borrower_demanded_on > Date.current
      errors.add(:borrower_demanded_on, :cannot_be_in_the_future)
    end
  end

  def outstanding_amount_is_less_than_demanded_amount
    return unless borrower_demand_outstanding && amount_demanded

    if borrower_demand_outstanding >= amount_demanded
      errors.add(:borrower_demand_outstanding, :too_high)
    end
  end
end
