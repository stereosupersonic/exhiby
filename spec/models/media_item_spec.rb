# == Schema Information
#
# Table name: media_items
#
#  id               :bigint           not null, primary key
#  copyright        :string
#  description      :text
#  exif_metadata    :jsonb
#  license          :string
#  media_type       :string           not null
#  published_at     :datetime
#  reviewed_at      :datetime
#  source           :string
#  status           :string           default("draft"), not null
#  submitted_at     :datetime
#  technique_legacy :string
#  title            :string           not null
#  year             :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  artist_id        :bigint
#  reviewed_by_id   :bigint
#  technique_id     :bigint
#  uploaded_by_id   :bigint           not null
#
# Indexes
#
#  index_media_items_on_artist_id       (artist_id)
#  index_media_items_on_media_type      (media_type)
#  index_media_items_on_published_at    (published_at)
#  index_media_items_on_reviewed_by_id  (reviewed_by_id)
#  index_media_items_on_status          (status)
#  index_media_items_on_technique_id    (technique_id)
#  index_media_items_on_uploaded_by_id  (uploaded_by_id)
#  index_media_items_on_year            (year)
#
# Foreign Keys
#
#  fk_rails_...  (artist_id => artists.id) ON DELETE => restrict
#  fk_rails_...  (reviewed_by_id => users.id)
#  fk_rails_...  (technique_id => techniques.id)
#  fk_rails_...  (uploaded_by_id => users.id)
#
require "rails_helper"

RSpec.describe MediaItem do
  describe "factory" do
    it "has a valid factory" do
      expect(build(:media_item)).to be_valid
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:uploaded_by).class_name("User") }
    it { is_expected.to belong_to(:reviewed_by).class_name("User").optional }
    it { is_expected.to have_many(:media_taggings).dependent(:destroy) }
    it { is_expected.to have_many(:media_tags).through(:media_taggings) }
    it { is_expected.to have_one_attached(:file) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_length_of(:title).is_at_most(255) }
    it { is_expected.to validate_presence_of(:media_type) }
    it { is_expected.to validate_inclusion_of(:media_type).in_array(MediaItem::MEDIA_TYPES) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_inclusion_of(:status).in_array(MediaItem::STATUSES) }
  end

  describe "scopes" do
    let!(:draft_item) { create(:media_item, status: "draft") }
    let!(:pending_item) { create(:media_item, :pending_review) }
    let!(:published_item) { create(:media_item, :published) }

    describe ".draft" do
      it "returns only draft items" do
        expect(described_class.draft).to contain_exactly(draft_item)
      end
    end

    describe ".pending_review" do
      it "returns only pending review items" do
        expect(described_class.pending_review).to contain_exactly(pending_item)
      end
    end

    describe ".published" do
      it "returns only published items" do
        expect(described_class.published).to contain_exactly(published_item)
      end
    end

    describe ".by_type" do
      let!(:video_item) { create(:media_item, :video) }

      it "filters by media type" do
        expect(described_class.by_type("video")).to contain_exactly(video_item)
      end

      it "returns all when type is blank" do
        expect(described_class.by_type(nil)).to include(draft_item, pending_item, published_item, video_item)
      end
    end

    describe ".by_year" do
      let!(:item_2020) { create(:media_item, year: 2020) }

      it "filters by year" do
        expect(described_class.by_year(2020)).to contain_exactly(item_2020)
      end
    end

    describe ".search" do
      let!(:searchable_item) { create(:media_item, title: "Unique Searchable Title") }

      it "searches by title" do
        expect(described_class.search("Unique")).to contain_exactly(searchable_item)
      end
    end
  end

  describe "status methods" do
    describe "#draft?" do
      it "returns true for draft status" do
        media_item = build(:media_item, status: "draft")
        expect(media_item.draft?).to be true
      end

      it "returns false for non-draft status" do
        media_item = build(:media_item, status: "published")
        expect(media_item.draft?).to be false
      end
    end

    describe "#pending_review?" do
      it "returns true for pending_review status" do
        media_item = build(:media_item, status: "pending_review")
        expect(media_item.pending_review?).to be true
      end
    end

    describe "#published?" do
      it "returns true for published status" do
        media_item = build(:media_item, status: "published")
        expect(media_item.published?).to be true
      end
    end
  end

  describe "workflow methods" do
    describe "#submit_for_review!" do
      it "changes status from draft to pending_review" do
        media_item = create(:media_item, status: "draft")
        expect { media_item.submit_for_review! }
          .to change { media_item.status }.from("draft").to("pending_review")
      end

      it "sets submitted_at timestamp" do
        media_item = create(:media_item, status: "draft")
        freeze_time do
          media_item.submit_for_review!
          expect(media_item.submitted_at).to eq(Time.current)
        end
      end

      it "returns false if not in draft status" do
        media_item = create(:media_item, :published)
        expect(media_item.submit_for_review!).to be false
      end
    end

    describe "#publish!" do
      let(:reviewer) { create(:user) }

      it "changes status from pending_review to published" do
        media_item = create(:media_item, :pending_review)
        expect { media_item.publish!(reviewer) }
          .to change { media_item.status }.from("pending_review").to("published")
      end

      it "sets published_at and reviewer info" do
        media_item = create(:media_item, :pending_review)
        freeze_time do
          media_item.publish!(reviewer)
          expect(media_item.published_at).to eq(Time.current)
          expect(media_item.reviewed_by).to eq(reviewer)
          expect(media_item.reviewed_at).to eq(Time.current)
        end
      end

      it "returns false if not in pending_review status" do
        media_item = create(:media_item, status: "draft")
        expect(media_item.publish!(reviewer)).to be false
      end
    end

    describe "#reject!" do
      let(:reviewer) { create(:user) }

      it "changes status from pending_review to draft" do
        media_item = create(:media_item, :pending_review)
        expect { media_item.reject!(reviewer) }
          .to change { media_item.status }.from("pending_review").to("draft")
      end

      it "clears submitted_at" do
        media_item = create(:media_item, :pending_review)
        media_item.reject!(reviewer)
        expect(media_item.submitted_at).to be_nil
      end
    end

    describe "#unpublish!" do
      it "changes status from published to draft" do
        media_item = create(:media_item, :published)
        expect { media_item.unpublish! }
          .to change { media_item.status }.from("published").to("draft")
      end

      it "clears published_at and submitted_at" do
        media_item = create(:media_item, :published)
        media_item.unpublish!
        expect(media_item.published_at).to be_nil
        expect(media_item.submitted_at).to be_nil
      end
    end
  end

  describe "media type methods" do
    describe "#image?" do
      it "returns true for image type" do
        media_item = build(:media_item, media_type: "image")
        expect(media_item.image?).to be true
      end
    end

    describe "#video?" do
      it "returns true for video type" do
        media_item = build(:media_item, media_type: "video")
        expect(media_item.video?).to be true
      end
    end

    describe "#pdf?" do
      it "returns true for pdf type" do
        media_item = build(:media_item, media_type: "pdf")
        expect(media_item.pdf?).to be true
      end
    end
  end

  describe "tag methods" do
    describe "#tag_list" do
      it "returns comma-separated tag names" do
        media_item = create(:media_item)
        tag1 = create(:media_tag, name: "History")
        tag2 = create(:media_tag, name: "Art")
        media_item.media_tags << tag1
        media_item.media_tags << tag2

        expect(media_item.tag_list).to eq("History, Art")
      end
    end

    describe "#tag_list=" do
      it "creates and assigns tags from comma-separated string" do
        media_item = create(:media_item)
        media_item.tag_list = "History, Art, Culture"

        expect(media_item.media_tags.pluck(:name)).to contain_exactly("History", "Art", "Culture")
      end

      it "reuses existing tags" do
        existing_tag = create(:media_tag, name: "History")
        media_item = create(:media_item)
        media_item.tag_list = "History, Art"

        expect(media_item.media_tags).to include(existing_tag)
        expect(MediaTag.where(name: "History").count).to eq(1)
      end
    end
  end

  describe "constants" do
    it "defines STATUSES" do
      expect(MediaItem::STATUSES).to eq(%w[draft pending_review published])
    end

    it "defines MEDIA_TYPES" do
      expect(MediaItem::MEDIA_TYPES).to eq(%w[image video pdf])
    end
  end

  describe "EXIF metadata" do
    describe "#exif_metadata" do
      it "defaults to empty hash for non-image types" do
        media_item = create(:media_item, :video)
        expect(media_item.exif_metadata).to eq({})
      end

      it "extracts EXIF data automatically for images" do
        user = create(:user)
        file = Rack::Test::UploadedFile.new(
          Rails.root.join("spec/fixtures/files/testbild_katze_exif_v2.jpg"),
          "image/jpeg"
        )
        media_item = MediaItem.build_with_file(
          file: file,
          uploaded_by: user,
          media_type: "image"
        )
        media_item.save!

        expect(media_item.title).to eq("Testbild Katze")
        # Note: EXIF extraction may have encoding issues with special characters
        expect(media_item.description).to be_present
        expect(media_item.description).to include("Testbild einer Katze")

        expect(media_item.exif_metadata).to be_present
        expect(media_item.exif_metadata["Artist"]).to eq("Testbild Katze")
        expect(media_item.exif_metadata["XPTitle"]).to eq("Testbild Katze")
        expect(media_item.exif_metadata["FileType"]).to eq("JPEG")
        expect(media_item.exif_metadata["MIMEType"]).to eq("image/jpeg")
        expect(media_item.exif_metadata["ImageWidth"]).to eq("512")
        expect(media_item.exif_metadata["ImageHeight"]).to eq("512")
      end

      it "stores EXIF data as JSONB" do
        media_item = create(:media_item)
        exif_data = {
          "Title" => "Test Image Title",
          "Description" => "A beautiful landscape photo",
          "Make" => "Canon",
          "Model" => "EOS 5D Mark IV",
          "DateTimeOriginal" => "2024-06-15 14:30:00",
          "Keywords" => "nature, landscape, mountains"
        }

        media_item.update!(exif_metadata: exif_data)
        media_item.reload

        expect(media_item.exif_metadata).to eq(exif_data)
        expect(media_item.exif_metadata["Title"]).to eq("Test Image Title")
        expect(media_item.exif_metadata["Description"]).to eq("A beautiful landscape photo")
      end

      it "persists title from EXIF data" do
        media_item = create(:media_item)
        media_item.update!(exif_metadata: { "Title" => "EXIF Title" })

        expect(media_item.reload.exif_metadata["Title"]).to eq("EXIF Title")
      end

      it "persists title and store it to EXIF data" do
        media_item = create(:media_item)
        media_item.update!(exif_metadata: { "Title" => "EXIF Title" })

        expect(media_item.reload.exif_metadata["Title"]).to eq("EXIF Title")

        media_item.title = "New Title"
        media_item.save!
        expect(media_item.reload.exif_metadata["Title"]).to eq("New Title")
      end

      it "persists description from EXIF data" do
        media_item = create(:media_item)
        media_item.update!(exif_metadata: { "Description" => "EXIF Description" })

        expect(media_item.reload.exif_metadata["Description"]).to eq("EXIF Description")

        media_item.description = "New Description"
        media_item.save!
        expect(media_item.reload.exif_metadata["Description"]).to eq("New Description")
      end

      it "persists keywords/tags from EXIF data" do
        media_item = create(:media_item)
        media_item.update!(exif_metadata: { "Keywords" => "tag1, tag2, tag3" })

        expect(media_item.reload.exif_metadata["Keywords"]).to eq("tag1, tag2, tag3")
      end
    end

    describe "#has_exif_data?" do
      it "returns false when exif_metadata is empty" do
        media_item = create(:media_item, :video)
        expect(media_item.has_exif_data?).to be false
      end

      it "returns false when exif_metadata is nil" do
        media_item = create(:media_item)
        media_item.update_column(:exif_metadata, nil)
        expect(media_item.has_exif_data?).to be false
      end

      it "returns true when exif_metadata has data" do
        media_item = create(:media_item, exif_metadata: { "Make" => "Canon" })
        expect(media_item.has_exif_data?).to be true
      end

      it "returns true when exif_metadata contains title" do
        media_item = create(:media_item, exif_metadata: { "Title" => "My Photo" })
        expect(media_item.has_exif_data?).to be true
      end

      it "returns true when exif_metadata contains description" do
        media_item = create(:media_item, exif_metadata: { "Description" => "Photo description" })
        expect(media_item.has_exif_data?).to be true
      end
    end

    describe "EXIF sync on update" do
      it "syncs title to all EXIF title fields" do
        media_item = create(:media_item, exif_metadata: { "Title" => "Old Title", "Make" => "Canon" })
        media_item.update!(title: "New Title")

        expect(media_item.exif_metadata["Title"]).to eq("New Title")
        expect(media_item.exif_metadata["ObjectName"]).to eq("New Title")
        expect(media_item.exif_metadata["Headline"]).to eq("New Title")
        expect(media_item.exif_metadata["Make"]).to eq("Canon")
      end

      it "syncs description to all EXIF description fields" do
        media_item = create(:media_item, exif_metadata: { "Description" => "Old Desc", "Make" => "Canon" })
        media_item.update!(description: "New Description")

        expect(media_item.exif_metadata["Description"]).to eq("New Description")
        expect(media_item.exif_metadata["ImageDescription"]).to eq("New Description")
        expect(media_item.exif_metadata["Caption-Abstract"]).to eq("New Description")
        expect(media_item.exif_metadata["Make"]).to eq("Canon")
      end

      it "syncs both title and description when both change" do
        media_item = create(:media_item, exif_metadata: { "Title" => "Old", "Description" => "Old" })
        media_item.update!(title: "New Title", description: "New Description")

        expect(media_item.exif_metadata["Title"]).to eq("New Title")
        expect(media_item.exif_metadata["Description"]).to eq("New Description")
      end

      it "does not sync when exif_metadata is empty" do
        media_item = create(:media_item, :video)
        media_item.update!(title: "New Title")

        expect(media_item.exif_metadata).to eq({})
      end

      it "does not sync for non-image media types" do
        media_item = create(:media_item, :video, exif_metadata: { "Title" => "Old" })
        media_item.update!(title: "New Title")

        expect(media_item.exif_metadata["Title"]).to eq("Old")
      end

      it "preserves other EXIF fields when syncing" do
        media_item = create(:media_item, exif_metadata: {
          "Title" => "Old Title",
          "Make" => "Canon",
          "Model" => "EOS 5D",
          "DateTimeOriginal" => "2024-01-01"
        })
        media_item.update!(title: "New Title")

        expect(media_item.exif_metadata["Title"]).to eq("New Title")
        expect(media_item.exif_metadata["Make"]).to eq("Canon")
        expect(media_item.exif_metadata["Model"]).to eq("EOS 5D")
        expect(media_item.exif_metadata["DateTimeOriginal"]).to eq("2024-01-01")
      end
    end
  end
end
