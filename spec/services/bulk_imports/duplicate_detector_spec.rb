require "rails_helper"

RSpec.describe BulkImports::DuplicateDetector do
  describe "#call" do
    context "with a blank phash" do
      it "returns not duplicate" do
        result = described_class.call(nil)

        expect(result[:duplicate]).to be false
      end

      it "returns not duplicate for empty string" do
        result = described_class.call("")

        expect(result[:duplicate]).to be false
      end
    end

    context "when checking batch duplicates" do
      let(:phash) { "abc123def456789a" }
      let(:batch_phashes) do
        {
          phash => { id: 42, filename: "existing_image.jpg" }
        }
      end

      it "detects a duplicate in the batch" do
        result = described_class.call(phash, batch_phashes: batch_phashes)

        expect(result[:duplicate]).to be true
        expect(result[:match_type]).to eq(:batch)
        expect(result[:existing_media_item_id]).to eq(42)
        expect(result[:existing_title]).to eq("existing_image.jpg")
        expect(result[:similarity_percentage]).to eq(100)
      end

      it "returns not duplicate when phash not in batch" do
        result = described_class.call("different_hash123", batch_phashes: batch_phashes)

        expect(result[:duplicate]).to be false
      end
    end

    context "when checking database duplicates" do
      let(:phash) { "abc123def456789a" }
      let!(:existing_media_item) { create(:media_item, phash: phash, title: "Existing Image") }

      it "detects a duplicate in the database" do
        result = described_class.call(phash)

        expect(result[:duplicate]).to be true
        expect(result[:match_type]).to eq(:database)
        expect(result[:existing_media_item_id]).to eq(existing_media_item.id)
        expect(result[:existing_title]).to eq("Existing Image")
        expect(result[:similarity_percentage]).to eq(100)
      end

      it "returns not duplicate when phash not in database" do
        result = described_class.call("different_hash123")

        expect(result[:duplicate]).to be false
      end
    end

    context "when duplicate exists in both batch and database" do
      let(:phash) { "abc123def456789a" }
      let(:batch_phashes) do
        {
          phash => { id: 99, filename: "batch_image.jpg" }
        }
      end
      let!(:existing_media_item) { create(:media_item, phash: phash, title: "Database Image") }

      it "prioritizes batch detection over database" do
        result = described_class.call(phash, batch_phashes: batch_phashes)

        expect(result[:duplicate]).to be true
        expect(result[:match_type]).to eq(:batch)
        expect(result[:existing_media_item_id]).to eq(99)
      end
    end

    context "with no duplicates" do
      let(:phash) { "unique_hash_1234" }

      it "returns not duplicate" do
        result = described_class.call(phash)

        expect(result[:duplicate]).to be false
      end
    end
  end
end
