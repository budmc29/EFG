class LoanCategoryValidators
  include ActiveModel::Validations

  CategoryB = [
    PercentageValidator.new(attribute: :security_proportion, minimum: 0.1, maximum: 99.9),
    SecurityTypesValidator.new
  ].freeze

  CategoryC = [
    PercentageValidator.new(attribute: :original_overdraft_proportion, minimum: 0.0, maximum: 99.9),
    PercentageValidator.new(attribute: :refinance_security_proportion, minimum: 0.1, maximum: 100.0)
  ].freeze

  CategoryD = [
    PercentageValidator.new(attribute: :refinance_security_proportion, minimum: 0.1, maximum: 100.0),
    PresenceValidator.new(attributes: [ :current_refinanced_amount, :final_refinanced_amount ])
  ].freeze

  CategoryEAndG = [
    PresenceValidator.new(attributes: :loan_sub_category_id),
    PresenceValidator.new(attributes: :overdraft_limit),
    InclusionValidator.new(attributes: :overdraft_maintained, in: [ true ])
  ].freeze

  CategoryFAndH = [
    PresenceValidator.new(attributes: :invoice_discount_limit),
    PercentageValidator.new(attribute: :debtor_book_coverage, minimum: 1.0, maximum: 99.9),
    PercentageValidator.new(attribute: :debtor_book_topup, minimum: 1.0, maximum: 30.0),
    PercentageValidator.new(attribute: :total_prepayment, minimum: 0, maximum: 100.0),
  ].freeze

  def self.for_category(loan_category_id)
    {
      LoanCategory::TypeB.id => CategoryB,
      LoanCategory::TypeC.id => CategoryC,
      LoanCategory::TypeD.id => CategoryD,
      LoanCategory::TypeE.id => CategoryEAndG,
      LoanCategory::TypeF.id => CategoryFAndH,
      LoanCategory::TypeG.id => CategoryEAndG,
      LoanCategory::TypeH.id => CategoryFAndH
    }.fetch(loan_category_id, [])
  end

end
