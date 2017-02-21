class CfeUserLender
  def lending_limits
    LendingLimit.none
  end

  def loans
    Loan.all
  end

  def users
    CfeUser.all
  end

  def can_access_all_loan_schemes?
    true
  end

  def new_legal_agreement_signed?
    false
  end
end
