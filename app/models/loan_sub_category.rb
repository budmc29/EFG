class LoanSubCategory
  include StaticAssociation

  attr_accessor :loan_category_id, :name

  record id: 1 do |r|
    r.loan_category_id = LoanCategory::TypeE.id
    r.name = "Overdrafts"
  end

  record id: 2 do |r|
    r.loan_category_id = LoanCategory::TypeE.id
    r.name = "Fixed Term Revolving Credit Facilities"
  end

  record id: 3 do |r|
    r.loan_category_id = LoanCategory::TypeE.id
    r.name = "Business Credit (or Charge) Cards"
  end

  record id: 4 do |r|
    r.loan_category_id = LoanCategory::TypeE.id
    r.name = "Bonds & Guarantees (Performance Bonds, VAT Deferment etc.)"
  end

  record id: 5 do |r|
    r.loan_category_id = LoanCategory::TypeE.id
    r.name = "BACS facilities"
  end

  record id: 6 do |r|
    r.loan_category_id = LoanCategory::TypeE.id
    r.name = "Stocking Finance"
  end

  record id: 7 do |r|
    r.loan_category_id = LoanCategory::TypeE.id
    r.name = "Import Finance (Letters of Credit, Import Loans etc.)"
  end

  record id: 8 do |r|
    r.loan_category_id = LoanCategory::TypeE.id
    r.name = "Merchant Services"
  end

  record id: 9 do |r|
    r.loan_category_id = LoanCategory::TypeE.id
    r.name = "Multi-option Facilities (setting a limit which can be used across
              a variety of the above)"
  end

  def loan_category
    LoanCategory.find(loan_category_id)
  end
end
