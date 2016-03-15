shared_context "State Aid Letter Content" do
  def render_pdf_content(loan: nil, pdf_opts: {})
    loan ||= FactoryGirl.create(:loan, :completed, :offered)
    pdf ||= described_class.new(loan, pdf_opts)
    reader = PDF::Reader.new(StringIO.new(pdf.render))
    # Note: replace line breaks to make assertions easier
    reader.pages.collect { |page| page.to_s }.join(" ").gsub("\n", ' ')
  end
end
