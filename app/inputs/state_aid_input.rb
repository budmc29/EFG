class StateAidInput < CurrencyInput
  def input(wrapper_options)
    options[:unit] = '€'
    input_html_options[:disabled] = true

    super + @builder.button(:submit, 'State Aid Calculation', class: 'btn-info')
  end
end
