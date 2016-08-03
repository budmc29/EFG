class RepaymentProfileValidator < BaseValidator
  def validate(record)
    if record.repayment_profile.blank?
      add_error(record, :repayment_profile, error_type: :blank)

      return
    end

    unless allowed_repayment_profile?(record)
      add_error(record, :repayment_profile)

      return
    end

    if fixed_amount_repayment_profile?(record) &&
       record.fixed_repayment_amount.blank?
      add_error(record, :fixed_repayment_amount, error_type: :blank)
    end
  end

  private

  def allowed_repayment_profile?(record)
    PremiumSchedule::REPAYMENT_PROFILES.include?(record.repayment_profile)
  end

  def fixed_amount_repayment_profile?(record)
    record.repayment_profile == PremiumSchedule::FIXED_AMOUNT_REPAYMENT_PROFILE
  end
end
