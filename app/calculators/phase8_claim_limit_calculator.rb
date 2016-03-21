class Phase8ClaimLimitCalculator < Phase7ClaimLimitCalculator
  def phase
    Phase.find(8)
  end
end
