class Phase7ClaimLimitCalculator < Phase6ClaimLimitCalculator
  def phase
    Phase.find(7)
  end
end
