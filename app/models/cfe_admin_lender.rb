class CfeAdminLender
  def users
    CfeAdmin.all
  end

  def can_access_all_loan_schemes?
    true
  end

  def new_legal_agreement_signed?
    false
  end
end
