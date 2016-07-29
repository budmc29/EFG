class CompanyRegistrationDataCorrection < DataCorrectionPresenter
  include BasicDataCorrectable

  data_corrects :company_registration, skip_validation: true

  validates :company_registration, presence: true, if: ->(data_correction) {
    data_correction.loan.legal_form.requires_company_registration
  }
end
