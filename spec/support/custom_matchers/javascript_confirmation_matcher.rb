RSpec::Matchers.define :have_javascript_confirmation do |expected|
  match do |element|
    expect(element["data-confirm"]).to eq(expected)
  end

  failure_message do |element|
    "expected javascript confirmation text would equal '#{expected}', but " \
    "was '#{element['data-confirm']}'"
  end
end
