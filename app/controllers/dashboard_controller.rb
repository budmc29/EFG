class DashboardController < ApplicationController
  def show
    if current_user.can_view?(LoanAlerts)
      @lending_limit_utilisations      = setup_lending_limit_utilisations
      @not_progressed_alerts_presenter = not_progressed_loans_groups
      @not_drawn_alerts_presenter      = not_drawn_loans_groups
      @not_demanded_alerts_presenter   = not_demanded_loans_groups
      @not_closed_presenter            = not_closed_loans_groups
    end

    if current_user.can_view?(ClaimLimitCalculator)
      @claim_limit_calculators = setup_claim_limit_calculators
    end
  end

  private

  def setup_claim_limit_calculators
    Phase.all.reverse.each_with_object([]) do |phase, memo|
      calculator = phase.rules.claim_limit_calculator.new(current_lender)
      memo << calculator unless calculator.total_amount.zero?
    end
  end

  def setup_lending_limit_utilisations
    current_lender.lending_limits.active.map do |lending_limit|
      LendingLimitUtilisation.new(lending_limit)
    end
  end

  def not_drawn_loans_groups
    alert = LoanAlerts::NotDrawn.new(current_lender)
    LoanAlerts::PriorityGrouping.new(alert)
  end

  def not_demanded_loans_groups
    alert = LoanAlerts::NotDemanded.new(current_lender)
    LoanAlerts::PriorityGrouping.new(alert)
  end

  def not_progressed_loans_groups
    alert = LoanAlerts::NotProgressed.new(current_lender)
    LoanAlerts::PriorityGrouping.new(alert)
  end

  def not_closed_loans_groups
    alert = LoanAlerts::NotClosed.new(current_lender)
    LoanAlerts::PriorityGrouping.new(alert)
  end
end
