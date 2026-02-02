require "rails_helper"

RSpec.describe MediaItems::SearchQuery do
  describe "#call" do
    let!(:published_image) { create(:media_item, :published, media_type: "image", year: 2023, title: "Sunset Photo") }
    let!(:draft_image) { create(:media_item, status: "draft", media_type: "image", year: 2022) }
    let!(:published_video) { create(:media_item, :published, media_type: "video", year: 2023) }
    let!(:published_pdf) { create(:media_item, :published, media_type: "pdf", year: 2021) }

    context "without filters" do
      it "returns all media items" do
        result = described_class.new.call

        expect(result).to include(published_image, draft_image, published_video, published_pdf)
      end
    end

    context "with status filter" do
      it "filters by published status" do
        result = described_class.new(MediaItem.all, status: "published").call

        expect(result).to include(published_image, published_video, published_pdf)
        expect(result).not_to include(draft_image)
      end

      it "filters by draft status" do
        result = described_class.new(MediaItem.all, status: "draft").call

        expect(result).to include(draft_image)
        expect(result).not_to include(published_image, published_video, published_pdf)
      end
    end

    context "with media_type filter" do
      it "filters by image type using media_type param" do
        result = described_class.new(MediaItem.all, media_type: "image").call

        expect(result).to include(published_image, draft_image)
        expect(result).not_to include(published_video, published_pdf)
      end

      it "filters by video type using type param" do
        result = described_class.new(MediaItem.all, type: "video").call

        expect(result).to include(published_video)
        expect(result).not_to include(published_image, draft_image, published_pdf)
      end
    end

    context "with year filter" do
      it "filters by year" do
        result = described_class.new(MediaItem.all, year: 2023).call

        expect(result).to include(published_image, published_video)
        expect(result).not_to include(draft_image, published_pdf)
      end
    end

    context "with search query" do
      it "filters by title" do
        result = described_class.new(MediaItem.all, q: "Sunset").call

        expect(result).to include(published_image)
        expect(result).not_to include(draft_image, published_video, published_pdf)
      end
    end

    context "with combined filters" do
      it "applies all filters together" do
        result = described_class.new(MediaItem.all, status: "published", media_type: "image", year: 2023).call

        expect(result).to eq([ published_image ])
      end

      it "returns empty when no items match all filters" do
        result = described_class.new(MediaItem.all, status: "draft", media_type: "video").call

        expect(result).to be_empty
      end
    end

    context "with custom base relation" do
      it "respects the provided base relation" do
        base_relation = MediaItem.where(media_type: "image")
        result = described_class.new(base_relation, status: "published").call

        expect(result).to eq([ published_image ])
      end
    end

    context "with blank filter values" do
      it "ignores blank status" do
        result = described_class.new(MediaItem.all, status: "").call

        expect(result.count).to eq(4)
      end

      it "ignores blank media_type" do
        result = described_class.new(MediaItem.all, media_type: nil).call

        expect(result.count).to eq(4)
      end
    end
  end
end
