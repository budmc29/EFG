class LoanDemandToBorrower
  include LoanPresenter
  include LoanStateTransition

  transition from: Loan::Guaranteed, to: Loan::LenderDemand, event: LoanEvent::DemandToBorrower

  before_save :store_loan_columns
  after_save :create_demand_to_borrower

  attr_reader :amount_demanded, :borrower_demanded_on

  validates_presence_of :amount_demanded
  validates_presence_of :borrower_demanded_on
  validate :validate_gte_loan_initial_draw_date, if: :borrower_demanded_on
  validate :borrower_demanded_on_is_not_in_the_future, if: :borrower_demanded_on

  def amount_demanded=(value)
    @amount_demanded = value.present? ? Monetize.parse(value) : nil
  end

  def borrower_demanded_on=(value)
    @borrower_demanded_on = QuickDateFormatter.parse(value)
  end

  private
    def create_demand_to_borrower
      loan.demand_to_borrowers.create! do |demand_to_borrower|
        demand_to_borrower.created_by = modified_by
        demand_to_borrower.date_of_demand = borrower_demanded_on
        demand_to_borrower.demanded_amount = amount_demanded
        demand_to_borrower.modified_date = Date.current
      end
    end

    def store_loan_columns
      loan.amount_demanded = amount_demanded
      loan.borrower_demanded_on = borrower_demanded_on
    end

    def validate_gte_loan_initial_draw_date
      if borrower_demanded_on < loan.initial_draw_change.date_of_change
        errors.add(:borrower_demanded_on, :must_be_after_loan_initial_draw_date)
      end
    end

    def borrower_demanded_on_is_not_in_the_future
      if borrower_demanded_on > Date.current
        errors.add(:borrower_demanded_on, :cannot_be_in_the_future)
      end
    end
end
