FactoryGirl.define do
  factory :loan_entry do
    declaration_signed true
    business_name "Widgets PLC"
    legal_form_id 1
    interest_rate_type_id 1
    interest_rate 5.00
    fees 1000
    repayment_frequency_id 3
    postcode 'EC1R 4RP'
    turnover '12345'
    state_aid 3560
    state_aid_is_valid true
    repayment_profile PremiumSchedule::FIXED_TERM_REPAYMENT_PROFILE

    initialize_with {
      loan = FactoryGirl.build(:loan, :eligible)
      new(loan)
    }

    factory :loan_entry_type_b do
      loan_security_types [1]
      security_proportion 25.0

      initialize_with {
        loan = FactoryGirl.build(:loan, :eligible, loan_category_id: LoanCategory::TypeB.id)
        new(loan)
      }
    end

    factory :loan_entry_type_c do
      original_overdraft_proportion 20.0
      refinance_security_proportion 15.0

      initialize_with {
        loan = FactoryGirl.build(:loan, :eligible, loan_category_id: LoanCategory::TypeC.id)
        new(loan)
      }
    end

    factory :loan_entry_type_d do
      refinance_security_proportion 20.0
      current_refinanced_amount 10000.00
      final_refinanced_amount 20000.00

      initialize_with {
        loan = FactoryGirl.build(:loan, :eligible, loan_category_id: LoanCategory::TypeD.id)
        new(loan)
      }
    end

    factory :loan_entry_type_e do
      loan_sub_category_id 1
      overdraft_limit 1000000
      overdraft_maintained true

      initialize_with {
        loan = FactoryGirl.build(:loan, :eligible, loan_category_id: LoanCategory::TypeE.id)
        new(loan)
      }
    end

    factory :loan_entry_type_f do
      invoice_discount_limit 1000000
      debtor_book_coverage 5.0
      debtor_book_topup 20.0

      initialize_with {
        loan = FactoryGirl.build(:loan, :eligible, loan_category_id: LoanCategory::TypeF.id)
        new(loan)
      }
    end

    factory :loan_entry_type_g, parent: :loan_entry_type_e do
      initialize_with {
        loan = FactoryGirl.create(:loan, :eligible, loan_category_id: LoanCategory::TypeG.id)
        new(loan)
      }
    end

    factory :loan_entry_type_h, parent: :loan_entry_type_f do
      initialize_with {
        loan = FactoryGirl.create(:loan, :eligible, loan_category_id: LoanCategory::TypeH.id)
        new(loan)
      }
    end

  end
end
