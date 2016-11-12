class LoanSecurity < ActiveRecord::Base
  extend StaticAssociation::AssociationHelpers
  
  belongs_to :loan
  belongs_to_static :loan_security_type

  attr_accessible :loan_id, :loan_security_type_id
end
