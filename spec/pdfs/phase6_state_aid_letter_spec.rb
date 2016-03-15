require "rails_helper"

describe Phase6StateAidLetter do
  include_context "State Aid Letter Content" do  
    it_behaves_like "State Aid Letter PDF"
  end

  it "contains annex table" do
    pdf_content = render_pdf_content

    expect(pdf_content).to include("Fisheries")
    expect(pdf_content).to include("30,000")
    expect(pdf_content).to include("1408/2013")
    expect(pdf_content).to include("18/12/13")
  end
end
