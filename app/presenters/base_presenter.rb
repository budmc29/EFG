module BasePresenter
  extend ActiveSupport::Concern

  included do
    extend  ActiveModel::Naming
    extend  ActiveModel::Callbacks
    include ActiveModel::Conversion
    include ActiveModel::MassAssignmentSecurity
    include ActiveModel::Validations
  end

  module ClassMethods
    def attribute(name, options = {})
      methods = [name]

      unless options[:read_only]
        methods << "#{name}="
        attr_accessible name
      end

      delegate *methods, to: :presenter_object
    end

    def set_presenter_object(presenter_object)
      @presenter_object = presenter_object
    end

    attr_reader :presenter_object
  end

  def attributes=(attributes)
    sanitize_for_mass_assignment(attributes).each do |k, v|
      public_send("#{k}=", v)
    end
  end

  def persisted?
    false
  end

  def presenter_object
    send(self.class.presenter_object)
  end
end
