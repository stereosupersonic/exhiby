require "rails_helper"

RSpec.describe CollectionPresenter do
  let(:collection) { create(:collection) }
  let(:presenter) { described_class.new(collection) }

  describe "#status_badge_class" do
    it "returns bg-secondary for draft" do
      collection.status = "draft"
      expect(presenter.status_badge_class).to eq("bg-secondary")
    end

    it "returns bg-success for published" do
      collection.status = "published"
      expect(presenter.status_badge_class).to eq("bg-success")
    end

    it "returns bg-secondary for unknown status" do
      collection.status = "unknown"
      expect(presenter.status_badge_class).to eq("bg-secondary")
    end
  end

  describe "#status_name" do
    it "returns translated status name for draft" do
      collection.status = "draft"
      expect(presenter.status_name).to eq("Entwurf")
    end

    it "returns translated status name for published" do
      collection.status = "published"
      expect(presenter.status_name).to eq("Veröffentlicht")
    end
  end

  describe "#formatted_published_at" do
    it "returns formatted date when published" do
      collection.published_at = Time.zone.local(2024, 1, 15, 10, 30)
      expect(presenter.formatted_published_at).to include("Januar 2024")
    end

    it "returns not published message when nil" do
      collection.published_at = nil
      expect(presenter.formatted_published_at).to eq("Nicht veröffentlicht")
    end
  end

  describe "#formatted_published_at_short" do
    it "returns short formatted date when published" do
      collection.published_at = Time.zone.local(2024, 1, 15, 10, 30)
      expect(presenter.formatted_published_at_short).to include("15.")
    end

    it "returns not published message when nil" do
      collection.published_at = nil
      expect(presenter.formatted_published_at_short).to eq("Nicht veröffentlicht")
    end
  end

  describe "#creator_email" do
    it "returns the creator email address" do
      expect(presenter.creator_email).to eq(collection.created_by.email_address)
    end
  end

  describe "#media_items_count" do
    it "returns the count of media items" do
      create_list(:collection_item, 3, collection: collection)
      expect(presenter.media_items_count).to eq(3)
    end

    it "returns zero when no media items" do
      expect(presenter.media_items_count).to eq(0)
    end
  end

  describe "#category_name" do
    it "returns the category name" do
      expect(presenter.category_name).to eq(collection.collection_category.name)
    end

    it "returns nil when no category" do
      allow(collection).to receive(:collection_category).and_return(nil)
      expect(presenter.category_name).to be_nil
    end
  end

  describe "delegation" do
    it "delegates missing methods to the wrapped object" do
      expect(presenter.name).to eq(collection.name)
      expect(presenter.slug).to eq(collection.slug)
    end
  end
end
