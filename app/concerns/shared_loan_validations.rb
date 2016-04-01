module SharedLoanValidations
  extend ActiveSupport::Concern

  private

  def repayment_frequency_allowed
    return unless repayment_frequency_id.present? && repayment_duration.present?
    case repayment_frequency_id
    when 1
      errors.add(:repayment_frequency_id, :not_allowed) unless repayment_duration.total_months % 12 == 0
    when 2
      errors.add(:repayment_frequency_id, :not_allowed) unless repayment_duration.total_months % 6 == 0
    when 3
      errors.add(:repayment_frequency_id, :not_allowed) unless repayment_duration.total_months % 3 == 0
    end
  end

  def company_turnover_is_allowed
    if turnover < Money.new(0) || turnover > loan.rules.maximum_allowed_turnover
      errors.add(:turnover, :invalid)
    end
  end
end
