require "rails_helper"

RSpec.describe ExtractExifMetadataJob, type: :job do
  include ActiveJob::TestHelper

  describe "#perform" do
    context "with a valid image media item" do
      let(:media_item) { create(:media_item) }

      it "extracts and stores EXIF metadata in exif_metadata column" do
        expect {
          described_class.perform_now(media_item.id)
        }.to change { media_item.reload.exif_metadata }
      end

      it "stores title from EXIF in exif_metadata" do
        allow(ExifMetadataExtractor).to receive(:call).and_return(
          all_tags: { "Title" => "EXIF Title", "Make" => "Canon" },
          suggested_values: { title: "EXIF Title" }
        )

        described_class.perform_now(media_item.id)

        expect(media_item.reload.exif_metadata["Title"]).to eq("EXIF Title")
      end

      it "stores description from EXIF in exif_metadata" do
        allow(ExifMetadataExtractor).to receive(:call).and_return(
          all_tags: { "Description" => "EXIF Description", "Caption-Abstract" => "Caption" },
          suggested_values: { description: "EXIF Description" }
        )

        described_class.perform_now(media_item.id)

        expect(media_item.reload.exif_metadata["Description"]).to eq("EXIF Description")
      end

      it "stores keywords from EXIF in exif_metadata" do
        allow(ExifMetadataExtractor).to receive(:call).and_return(
          all_tags: { "Keywords" => "nature, landscape, mountains" },
          suggested_values: {}
        )

        described_class.perform_now(media_item.id)

        expect(media_item.reload.exif_metadata["Keywords"]).to eq("nature, landscape, mountains")
      end
    end

    context "when EXIF contains suggested values" do
      let(:media_item) { create(:media_item, title: "Original Title", description: nil) }

      it "updates title from EXIF data" do
        allow(ExifMetadataExtractor).to receive(:call).and_return(
          all_tags: { "Title" => "New EXIF Title" },
          suggested_values: { title: "New EXIF Title" }
        )

        described_class.perform_now(media_item.id)

        expect(media_item.reload.title).to eq("New EXIF Title")
      end

      it "updates description from EXIF data" do
        allow(ExifMetadataExtractor).to receive(:call).and_return(
          all_tags: { "Description" => "New EXIF Description" },
          suggested_values: { description: "New EXIF Description" }
        )

        described_class.perform_now(media_item.id)

        expect(media_item.reload.description).to eq("New EXIF Description")
      end

      it "updates year from EXIF date" do
        allow(ExifMetadataExtractor).to receive(:call).and_return(
          all_tags: { "DateTimeOriginal" => "2020-06-15 14:30:00" },
          suggested_values: { year: 2020 }
        )

        described_class.perform_now(media_item.id)

        expect(media_item.reload.year).to eq(2020)
      end

      it "updates copyright from EXIF data" do
        allow(ExifMetadataExtractor).to receive(:call).and_return(
          all_tags: { "Copyright" => "John Doe 2024" },
          suggested_values: { copyright: "John Doe 2024" }
        )

        described_class.perform_now(media_item.id)

        expect(media_item.reload.copyright).to eq("John Doe 2024")
      end

      it "updates source from EXIF artist" do
        allow(ExifMetadataExtractor).to receive(:call).and_return(
          all_tags: { "Artist" => "Jane Smith" },
          suggested_values: { source: "Jane Smith" }
        )

        described_class.perform_now(media_item.id)

        expect(media_item.reload.source).to eq("Jane Smith")
      end
    end

    context "when EXIF contains keywords" do
      let(:media_item) { create(:media_item) }

      it "creates tags from EXIF keywords string" do
        allow(ExifMetadataExtractor).to receive(:call).and_return(
          all_tags: { "Keywords" => "nature, landscape, mountains" },
          suggested_values: {}
        )

        expect {
          described_class.perform_now(media_item.id)
        }.to change { media_item.reload.media_tags.count }.by(3)

        expect(media_item.media_tags.pluck(:name)).to contain_exactly("nature", "landscape", "mountains")
      end

      it "creates tags from EXIF Subject field" do
        allow(ExifMetadataExtractor).to receive(:call).and_return(
          all_tags: { "Subject" => "art, painting" },
          suggested_values: {}
        )

        described_class.perform_now(media_item.id)

        expect(media_item.reload.media_tags.pluck(:name)).to contain_exactly("art", "painting")
      end

      it "clears existing tags when image changes" do
        existing_tag = create(:media_tag, name: "old_tag")
        media_item.media_tags << existing_tag

        allow(ExifMetadataExtractor).to receive(:call).and_return(
          all_tags: { "Keywords" => "new_tag" },
          suggested_values: {}
        )

        described_class.perform_now(media_item.id)

        expect(media_item.reload.media_tags.pluck(:name)).to eq(["new_tag"])
        expect(media_item.media_tags.pluck(:name)).not_to include("old_tag")
      end
    end

    context "with a video media item" do
      let(:media_item) { create(:media_item, :video) }

      it "does not extract EXIF metadata" do
        described_class.perform_now(media_item.id)
        expect(media_item.reload.exif_metadata).to eq({})
      end
    end

    context "with a non-existent media item" do
      it "does not raise an error" do
        expect {
          described_class.perform_now(999_999)
        }.not_to raise_error
      end
    end
  end

  describe "queue" do
    it "is queued in the default queue" do
      expect(described_class.new.queue_name).to eq("default")
    end
  end
end
