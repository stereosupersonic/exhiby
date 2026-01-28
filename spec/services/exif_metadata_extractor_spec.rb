require "rails_helper"

RSpec.describe ExifMetadataExtractor do
  describe ".call" do
    context "with a valid image file" do
      let(:file_path) { Rails.root.join("spec/fixtures/files/test_image.png") }

      it "returns a result hash with expected keys" do
        result = described_class.call(file_path)

        expect(result).to be_a(Hash)
        expect(result).to include(:all_tags, :grouped_tags, :suggested_values, :raw_tags_count)
      end

      it "extracts tags from the image" do
        result = described_class.call(file_path)

        expect(result[:raw_tags_count]).to be >= 0
        expect(result[:all_tags]).to be_a(Hash)
      end
    end

    context "with a non-existent file" do
      let(:file_path) { "/non/existent/file.jpg" }

      it "returns an empty result" do
        result = described_class.call(file_path)

        expect(result[:all_tags]).to eq({})
        expect(result[:grouped_tags]).to eq({})
        expect(result[:suggested_values]).to eq({})
        expect(result[:raw_tags_count]).to eq(0)
      end
    end

    context "with nil file path" do
      it "returns an empty result" do
        result = described_class.call(nil)

        expect(result[:all_tags]).to eq({})
        expect(result[:raw_tags_count]).to eq(0)
      end
    end

    context "with an empty file path" do
      it "returns an empty result" do
        result = described_class.call("")

        expect(result[:all_tags]).to eq({})
        expect(result[:raw_tags_count]).to eq(0)
      end
    end
  end

  describe "DISPLAY_TAGS" do
    it "defines tag groups" do
      expect(described_class::DISPLAY_TAGS).to include(:camera, :image, :capture, :date, :location, :author, :description)
    end
  end

  describe "FIELD_MAPPINGS" do
    it "defines mappings for form fields" do
      expect(described_class::FIELD_MAPPINGS).to include(:title, :description, :year, :copyright, :source)
    end
  end
end
