class DashboardController < ApplicationController

  include LoanAlerts

  def show
    @utilisation_presenter           = UtilisationPresenter.new(current_lender)
    @not_drawn_alerts_presenter      = LoanAlerts::Presenter.new(not_drawn_loans_groups)
    @demanded_alerts_presenter       = LoanAlerts::Presenter.new(demanded_loans_groups)
    @not_progressed_alerts_presenter = LoanAlerts::Presenter.new(not_progressed_loans_groups)
    @assumed_repaid_presenter        = LoanAlerts::Presenter.new(assumed_repaid_loans_groups)
  end

  private

  def not_drawn_loans_groups
    LoanAlerts::PriorityGrouping.new(not_drawn_loans, not_drawn_start_date, not_drawn_end_date).groups_hash
  end

  def demanded_loans_groups
    LoanAlerts::PriorityGrouping.new(demanded_loans, demanded_start_date, demanded_end_date).groups_hash
  end

  def not_progressed_loans_groups
    LoanAlerts::PriorityGrouping.new(not_progressed_loans, not_progressed_start_date, not_progressed_end_date).groups_hash
  end

  def assumed_repaid_loans_groups
    offered_group = LoanAlerts::PriorityGrouping.new(
      assumed_repaid_offered_loans,
      assumed_repaid_offered_start_date,
      assumed_repaid_offered_end_date,
      :maturity_date
    ).groups_hash

    guaranteed_group = LoanAlerts::PriorityGrouping.new(
      assumed_repaid_guaranteed_loans,
      assumed_repaid_guaranteed_start_date,
      assumed_repaid_guaranteed_end_date,
      :maturity_date
    ).groups_hash

    LoanAlerts::PriorityGrouping.merge_groups(offered_group, guaranteed_group)
  end

end


