class AuditorUserLender
  def loans
    Loan.all
  end

  def users
    AuditorUser.all
  end

  def can_access_all_loan_schemes?
    true
  end

  def new_legal_agreement_signed?
    false
  end
end
