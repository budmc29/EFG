class StateAidLetterDetails
  include ActiveModel::Model

  attr_accessor :applicant_name, :applicant_address1, :applicant_address2,
                :applicant_address3, :applicant_address4, :applicant_postcode,
                :letter_date

  def attributes
    {
      applicant_name: applicant_name,
      applicant_address1: applicant_address1,
      applicant_address2: applicant_address2,
      applicant_address3: applicant_address3,
      applicant_address4: applicant_address4,
      applicant_postcode: applicant_postcode,
      letter_date: letter_date,
    }
  end
end
