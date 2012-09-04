class LendingLimitUtilisationPresenter

  def initialize(lending_limit)
    @lending_limit = lending_limit
  end

  def group_header(index)
    if index == 1
      '<h3 class="allocation_divider">Previous Years</h3>'
    elsif index == 0
      '<h3 class="allocation_divider">Current Year</h3>'
    end
  end

  def title
    @lending_limit.title
  end

  def chart_colour
    if usage_percentage.to_f > 85.0
      "#ff0000"
    elsif usage_percentage.to_f > 50.0
      "#FF7E00"
    else
      "#00c000"
    end
  end

  def total_allocation
    @total_allocation ||= @lending_limit.allocation
  end

  def usage_amount
    @usage_amount ||= Money.new(@lending_limit.loans_using_lending_limit.sum(:amount))
  end

  def usage_percentage
    if allocation_has_loans?
      percentage = (usage_amount / total_allocation) * 100
      sprintf("%03.2f", percentage)
    else
      0
    end
  end

  private

  def allocation_has_loans?
    usage_amount > 0
  end

end