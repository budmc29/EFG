class LoanSubCategorySelectInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    unless options[:loan_category_id] 
      raise ArgumentError, 'Please specify the :loan_category_id'
    end

    @builder.collection_select(attribute_name, select_options, :id, :name, prompt: 'Please select', input_html: { class: 'input-xxlarge' })
  end

  private
  
  def select_options
    LoanSubCategory.all.select { |s| s.loan_category_id == options[:loan_category_id] }
  end
end
