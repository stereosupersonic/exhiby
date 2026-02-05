require "rails_helper"

RSpec.describe BulkImports::ProcessSingleImage do
  let(:user) { create(:user) }
  let(:bulk_import) { create(:bulk_import, created_by: user) }
  let(:file_path) { Rails.root.join("spec/fixtures/files/test_image.png") }
  let(:filename) { "test_image.png" }
  let(:csv_metadata) { {} }

  describe "#call" do
    subject(:result) do
      described_class.call(
        file_path: file_path,
        filename: filename,
        csv_metadata: csv_metadata,
        bulk_import: bulk_import,
        user: user
      )
    end

    context "with valid image file" do
      it "creates a media item" do
        expect { result }.to change(MediaItem, :count).by(1)
        expect(result[:success]).to be true
        expect(result[:media_item_id]).to be_present
      end

      it "assigns correct attributes" do
        result
        media_item = MediaItem.find(result[:media_item_id])

        expect(media_item.uploaded_by).to eq(user)
        expect(media_item.bulk_import).to eq(bulk_import)
        expect(media_item.media_type).to eq("image")
        expect(media_item.status).to eq("draft")
      end

      it "uses filename as title fallback" do
        result
        media_item = MediaItem.find(result[:media_item_id])

        expect(media_item.title).to eq("Test Image")
      end

      it "tracks attribute sources" do
        expect(result[:attribute_sources]).to include(title: "filename")
      end
    end

    context "with CSV metadata" do
      let(:csv_metadata) do
        {
          title: "CSV Title",
          description: "CSV Description",
          year: 2020,
          source: "CSV Source",
          copyright: "CSV Copyright"
        }
      end

      it "uses CSV values" do
        result
        media_item = MediaItem.find(result[:media_item_id])

        expect(media_item.title).to eq("CSV Title")
        expect(media_item.description).to eq("CSV Description")
        expect(media_item.year).to eq(2020)
        expect(media_item.source).to eq("CSV Source")
        expect(media_item.copyright).to eq("CSV Copyright")
      end

      it "tracks CSV as attribute source" do
        expect(result[:attribute_sources][:title]).to eq("csv")
      end
    end

    context "with CSV tags" do
      let(:csv_metadata) { { tags: [ "Tag1", "Tag2" ] } }

      it "creates media tags" do
        result
        media_item = MediaItem.find(result[:media_item_id])

        expect(media_item.media_tags.pluck(:name)).to contain_exactly("Tag1", "Tag2")
      end
    end

    context "with artist name in CSV" do
      let!(:artist) { create(:artist, name: "Max Mustermann") }
      let(:csv_metadata) { { artist_name: "Max Mustermann" } }

      it "assigns artist" do
        result
        media_item = MediaItem.find(result[:media_item_id])

        expect(media_item.artist).to eq(artist)
      end

      it "handles case-insensitive matching" do
        csv_with_case = { artist_name: "max mustermann" }
        result = described_class.call(
          file_path: file_path,
          filename: filename,
          csv_metadata: csv_with_case,
          bulk_import: bulk_import,
          user: user
        )

        media_item = MediaItem.find(result[:media_item_id])
        expect(media_item.artist).to eq(artist)
      end
    end

    context "with technique name in CSV" do
      let!(:technique) { create(:technique, name: "Fotografie") }
      let(:csv_metadata) { { technique_name: "Fotografie" } }

      it "assigns technique" do
        result
        media_item = MediaItem.find(result[:media_item_id])

        expect(media_item.technique).to eq(technique)
      end
    end

    context "with non-existent file" do
      let(:file_path) { "/nonexistent/file.jpg" }

      it "returns error" do
        expect(result[:success]).to be false
        expect(result[:errors]).to be_present
      end
    end

    context "with invalid file type" do
      let(:file_path) { Rails.root.join("spec/fixtures/files/test_document.pdf") }

      it "returns error" do
        expect(result[:success]).to be false
        expect(result[:errors]).to include(/Invalid file type/)
      end
    end
  end
end
