class LoanRepay
  include LoanPresenter
  include LoanStateTransition

  transition from: [Loan::Guaranteed, Loan::LenderDemand, Loan::Demanded],
             to: Loan::Repaid, event: LoanEvent::LoanRepaid

  attribute :repaid_on

  validates_presence_of :repaid_on

  validate :repaid_on_is_not_before_initial_draw_date
  validate :repaid_on_is_not_in_the_future

  private

  def repaid_on_is_not_before_initial_draw_date
    return if repaid_on.blank? || loan.initial_draw_change.blank?

    if repaid_on < loan.initial_draw_date
      errors.add(:repaid_on, :before_initial_draw_date)
    end
  end

  def repaid_on_is_not_in_the_future
    return if repaid_on.blank?

    if repaid_on > Date.current
      errors.add(:repaid_on, :in_the_future)
    end
  end
end
