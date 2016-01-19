require 'rails_helper'

describe FormatterConcern do
  module Formatter
    def self.format(_); end
    def self.parse(_); end
  end

  let(:klass) {
    Class.new do
      include FormatterConcern
      format :foo, with: Formatter
      def read_attribute(_); end
      def write_attribute(_, _); end
    end
  }
  let(:instance) { klass.new }

  describe 'reading' do
    it 'passes through the formatter and returns' do
      value = double
      formatted = double
      expect(instance).to receive(:read_attribute).with(:foo).and_return(value)
      expect(Formatter).to receive(:format).with(value).and_return(formatted)
      expect(instance.foo).to eq(formatted)
    end
  end

  describe 'writing' do
    it 'passes through the formatter and writes' do
      value = double
      formatted = double
      expect(Formatter).to receive(:parse).with(value).and_return(formatted)
      expect(instance).to receive(:write_attribute).with(:foo, formatted)
      instance.foo = value
    end
  end
end
