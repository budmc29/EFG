class RevertDemandedLoan
  include LoanPresenter
  include LoanStateTransition

  transition from: Loan::Demanded,
             to: Loan::LenderDemand,
             event: LoanEvent::DemandToBorrower
end
