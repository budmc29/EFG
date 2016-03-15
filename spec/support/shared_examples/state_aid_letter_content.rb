shared_context "State Aid Letter Content" do
  let(:loan) { FactoryGirl.create(:loan, :completed, :offered) }

  let(:pdf_content) {
    state_aid_letter = described_class.new(loan)
    reader = PDF::Reader.new(StringIO.new(state_aid_letter.render))
    # Note: replace line breaks to make assertions easier
    reader.pages.collect { |page| page.to_s }.join(" ").gsub("\n", ' ')
  }
end
