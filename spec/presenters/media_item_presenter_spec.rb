require "rails_helper"

RSpec.describe MediaItemPresenter do
  let(:media_item) { create(:media_item) }
  let(:presenter) { described_class.new(media_item) }

  describe "#status_badge_class" do
    it "returns bg-secondary for draft" do
      media_item.status = "draft"
      expect(presenter.status_badge_class).to eq("bg-secondary")
    end

    it "returns bg-warning text-dark for pending_review" do
      media_item.status = "pending_review"
      expect(presenter.status_badge_class).to eq("bg-warning text-dark")
    end

    it "returns bg-success for published" do
      media_item.status = "published"
      expect(presenter.status_badge_class).to eq("bg-success")
    end
  end

  describe "#status_name" do
    it "returns translated status name" do
      media_item.status = "draft"
      expect(presenter.status_name).to eq("Entwurf")
    end
  end

  describe "#media_type_badge_class" do
    it "returns bg-primary for image" do
      media_item.media_type = "image"
      expect(presenter.media_type_badge_class).to eq("bg-primary")
    end

    it "returns bg-info for video" do
      media_item.media_type = "video"
      expect(presenter.media_type_badge_class).to eq("bg-info")
    end

    it "returns bg-danger for pdf" do
      media_item.media_type = "pdf"
      expect(presenter.media_type_badge_class).to eq("bg-danger")
    end
  end

  describe "#media_type_name" do
    it "returns translated media type name" do
      media_item.media_type = "image"
      expect(presenter.media_type_name).to eq("Bild")
    end
  end

  describe "#uploader_name" do
    it "returns uploader email address" do
      expect(presenter.uploader_name).to eq(media_item.uploaded_by.email_address)
    end
  end

  describe "#formatted_published_at" do
    it "returns formatted date when published" do
      media_item.published_at = Time.zone.local(2024, 1, 15, 10, 30)
      expect(presenter.formatted_published_at).to include("Januar 2024")
    end

    it "returns not published message when nil" do
      media_item.published_at = nil
      expect(presenter.formatted_published_at).to eq("Nicht veröffentlicht")
    end
  end

  describe "#file_info" do
    it "returns filename and size" do
      expect(presenter.file_info).to include("test_image.png")
    end

    it "returns nil when no file attached" do
      media_item.file.detach
      expect(presenter.file_info).to be_nil
    end
  end

  describe "#phash_short" do
    it "returns first 8 characters of phash" do
      media_item.phash = "a1b2c3d4e5f67890"
      expect(presenter.phash_short).to eq("a1b2c3d4")
    end

    it "returns nil when phash is blank" do
      media_item.phash = nil
      expect(presenter.phash_short).to be_nil
    end

    it "returns nil when phash is empty string" do
      media_item.phash = ""
      expect(presenter.phash_short).to be_nil
    end
  end
end
