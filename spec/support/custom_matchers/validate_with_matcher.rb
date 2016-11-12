# RSpec matcher for validates_with.
# https://gist.github.com/2032846
# Usage:
#
#  describe User do
#    it { should validate_with CustomValidator }
#  end
#
RSpec::Matchers.define :validate_with do |validator|
  match do |subject|
    subject.class.validators.map(&:class).include? validator
  end

  description do
    "RSpec matcher for validates_with"
  end

  failure_message do |_text|
    "expected to validate with #{validator}"
  end

  failure_message_when_negated do |_text|
    "do not expected to validate with #{validator}"
  end
end
