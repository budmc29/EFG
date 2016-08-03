class BaseValidator < ActiveModel::Validator
  private

  def add_error(record, attribute, options = {})
    error_type = options.delete(:error_type) || :invalid
    options[:message] = I18n.translate(
      "validators.#{kind}.#{attribute}.#{error_type}"
    )

    record.errors.add(attribute, error_type, options)
  end
end
