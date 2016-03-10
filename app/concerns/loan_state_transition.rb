module LoanStateTransition
  extend ActiveSupport::Concern

  included do
    raise RuntimeError.new('LoanPresenter must be included.') unless ancestors.include?(LoanPresenter)

    before_save :transition_state
    after_save :log_state_change!
  end

  module ClassMethods
    def transition(options)
      @from_state = options[:from]
      @to_state = options[:to]
      @event = options[:event]
    end

    attr_reader :from_state, :to_state, :event
  end

  def initialize(loan)
    from_state = self.class.from_state
    allowed_from_states = from_state.is_a?(Array) ? from_state : [from_state]

    unless allowed_from_states.include?(loan.state)
      raise IncorrectLoanStateError.new("#{self.class.name} tried to " \
        "transition Loan:#{loan.id} with state:#{loan.state}")
    end

    super(loan)
  end

  def transition_to
    self.class.to_state
  end

  def event
    self.class.event
  end

  def transition_state
    loan.state = transition_to
  end

  def log_state_change!
    LoanStateChange.log(loan, event, loan.modified_by)
  end

end
