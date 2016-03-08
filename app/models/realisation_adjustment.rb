class RealisationAdjustment < Adjustment

  scope :pre_claim_limit, -> { where(post_claim_limit: false) }
  scope :post_claim_limit, -> { where(post_claim_limit: true) }

end
