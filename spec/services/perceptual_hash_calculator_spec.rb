require "rails_helper"

RSpec.describe PerceptualHashCalculator do
  let(:test_image_path) { Rails.root.join("spec/fixtures/files/testbild_katze_exif_v2.jpg") }

  describe "#call" do
    context "with a valid image file" do
      it "returns a 16-character hex string" do
        result = described_class.call(test_image_path)

        expect(result).to be_present
        expect(result).to match(/\A[0-9a-f]{16}\z/)
      end

      it "returns the same hash for the same image" do
        hash1 = described_class.call(test_image_path)
        hash2 = described_class.call(test_image_path)

        expect(hash1).to eq(hash2)
      end
    end

    context "with a non-existent file" do
      it "returns nil" do
        result = described_class.call("/non/existent/file.png")

        expect(result).to be_nil
      end
    end

    context "with an invalid image file" do
      let(:pdf_path) { Rails.root.join("spec/fixtures/files/test_document.pdf") }

      it "returns nil" do
        result = described_class.call(pdf_path)

        expect(result).to be_nil
      end
    end

    context "with a minimal image file" do
      let(:minimal_image_path) { Rails.root.join("spec/fixtures/files/test_image.png") }

      it "still returns a hash (may be uniform)" do
        result = described_class.call(minimal_image_path)

        expect(result).to be_present
        expect(result).to match(/\A[0-9a-f]{16}\z/)
      end
    end
  end

  describe "duplicate detection via identical hashes" do
    let(:duplicate_image_path) { Rails.root.join("tmp/duplicate_test_image.jpg") }

    before do
      FileUtils.cp(test_image_path, duplicate_image_path)
    end

    after do
      FileUtils.rm_f(duplicate_image_path)
    end

    it "returns identical hashes for identical images" do
      original_hash = described_class.call(test_image_path)
      duplicate_hash = described_class.call(duplicate_image_path)

      expect(original_hash).to eq(duplicate_hash)
    end
  end
end
