module LoanPresenter
  include BasePresenter

  included do
    attr_reader :loan

    delegate :modified_by, :modified_by=, to: :loan

    define_model_callbacks :save
  end

  set_presenter_object :loan

  def initialize(loan)
    @loan = loan
  end

  def save
    return false unless valid?
    loan.transaction do
      run_callbacks :save do
        loan.save!
      end
    end
  end
end
