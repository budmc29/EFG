class FixedRepaymentDurationOutstandingLoanValue
  def initialize(args)
    @args = args
    @drawdowns = args.delete(:drawdowns)
  end

  def amount
    drawdowns.sum(Money.new(0)) do |drawdown|
      OutstandingDrawdownValue.new(args.merge(drawdown: drawdown)).amount
    end
  end

  private

  attr_reader :args, :drawdowns
end
