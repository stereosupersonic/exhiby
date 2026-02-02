require "rails_helper"

RSpec.describe ApplicationHelper do
  describe "SITE_NAME" do
    it "defines the site name constant" do
      expect(described_class::SITE_NAME).to eq("OnlineMuseum Wartenberg")
    end
  end

  describe "#page_title" do
    it "appends site name to provided title" do
      expect(helper.page_title("Kunstschaffende")).to eq("Kunstschaffende | OnlineMuseum Wartenberg")
    end

    it "returns site name when no title provided" do
      expect(helper.page_title).to eq("OnlineMuseum Wartenberg")
    end

    it "returns site name when title is nil" do
      expect(helper.page_title(nil)).to eq("OnlineMuseum Wartenberg")
    end

    it "returns site name when title is blank" do
      expect(helper.page_title("")).to eq("OnlineMuseum Wartenberg")
    end

    it "uses content_for title when available and no title provided" do
      helper.content_for(:title, "Content For Title")
      expect(helper.page_title).to eq("Content For Title")
    end
  end

  describe "#meta_description" do
    it "returns content_for meta_description when set" do
      helper.content_for(:meta_description, "Custom description")
      expect(helper.meta_description).to eq("Custom description")
    end

    it "returns default description from i18n when not set" do
      expect(helper.meta_description).to eq(I18n.t("seo.default_description"))
    end
  end

  describe "#canonical_url" do
    before do
      allow(helper).to receive(:request).and_return(
        double(original_url: "https://example.com/page?query=1")
      )
    end

    it "returns content_for canonical_url when set" do
      helper.content_for(:canonical_url, "https://example.com/custom")
      expect(helper.canonical_url).to eq("https://example.com/custom")
    end

    it "returns request URL without query params when not set" do
      expect(helper.canonical_url).to eq("https://example.com/page")
    end
  end

  describe "#og_image_url" do
    it "returns content_for og_image when set" do
      helper.content_for(:og_image, "https://example.com/custom-image.jpg")
      expect(helper.og_image_url).to eq("https://example.com/custom-image.jpg")
    end

    it "returns default OG image URL when not set" do
      allow(helper).to receive(:image_url).with(described_class::DEFAULT_OG_IMAGE)
        .and_return("https://example.com/default-og.png")
      expect(helper.og_image_url).to eq("https://example.com/default-og.png")
    end
  end

  describe "#set_meta" do
    it "sets title content_for" do
      helper.set_meta(title: "Test Title")
      expect(helper.content_for(:title)).to eq("Test Title")
    end

    it "sets description content_for" do
      helper.set_meta(description: "Test description")
      expect(helper.content_for(:meta_description)).to eq("Test description")
    end

    it "sets image content_for" do
      helper.set_meta(image: "https://example.com/image.jpg")
      expect(helper.content_for(:og_image)).to eq("https://example.com/image.jpg")
    end

    it "sets canonical content_for" do
      helper.set_meta(canonical: "https://example.com/canonical")
      expect(helper.content_for(:canonical_url)).to eq("https://example.com/canonical")
    end

    it "sets multiple values at once" do
      helper.set_meta(title: "Title", description: "Desc")
      expect(helper.content_for(:title)).to eq("Title")
      expect(helper.content_for(:meta_description)).to eq("Desc")
    end

    it "does not set content_for when value is blank" do
      helper.set_meta(title: "", description: nil)
      expect(helper.content_for?(:title)).to be false
      expect(helper.content_for?(:meta_description)).to be false
    end
  end

  describe "#truncate_for_meta" do
    it "truncates text to specified length" do
      long_text = "A" * 200
      result = helper.truncate_for_meta(long_text, length: 155)
      expect(result.length).to be <= 158 # 155 + "..."
    end

    it "strips HTML tags" do
      html_text = "<p>Hello <strong>World</strong></p>"
      result = helper.truncate_for_meta(html_text)
      expect(result).to eq("Hello World")
    end

    it "squishes whitespace" do
      text_with_spaces = "Hello    World\n\nTest"
      result = helper.truncate_for_meta(text_with_spaces)
      expect(result).to eq("Hello World Test")
    end

    it "returns empty string for blank input" do
      expect(helper.truncate_for_meta(nil)).to eq("")
      expect(helper.truncate_for_meta("")).to eq("")
    end

    it "uses default length of 155" do
      long_text = "A" * 200
      result = helper.truncate_for_meta(long_text)
      expect(result).to end_with("...")
    end

    it "truncates at word boundary when possible" do
      text = "This is a test sentence that should be truncated"
      result = helper.truncate_for_meta(text, length: 30)
      # Result should end with "..." and the word before should be complete
      expect(result).to end_with("...")
      expect(result.length).to be <= 33 # 30 + "..."
    end
  end
end
