class LoanAdjustmentPresenter < SimpleDelegator
  include ActionView::Helpers::TagHelper

  def self.for_loan(loan)
    loan.adjustments.order(:date).map do |adjustment|
      new(adjustment)
    end
  end

  def formatted_date
    date.to_s(:screen)
  end

  def adjustment_type
    type.gsub("Adjustment", "")
  end

  def adjusted_amount
    amount.format
  end

  def adjusted_by_name
    created_by.name
  end

  def claim_limit_state
    if realisation_adjustment?
      [
        content_tag(:strong, claim_limit_description),
        tag(:br),
      ].join.html_safe
    end
  end

  private

  def claim_limit_description
    post_claim_limit? ? "Post Claim Limit" : "Pre Claim Limit"
  end

  def realisation_adjustment?
    type == RealisationAdjustment.to_s
  end
end
