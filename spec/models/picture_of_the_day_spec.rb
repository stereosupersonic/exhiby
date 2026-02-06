# == Schema Information
#
# Table name: pictures_of_the_day
#
#  id            :bigint           not null, primary key
#  caption       :string
#  description   :text
#  display_date  :date             not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  created_by_id :bigint           not null
#  media_item_id :bigint           not null
#
# Indexes
#
#  index_pictures_of_the_day_on_created_by_id  (created_by_id)
#  index_pictures_of_the_day_on_display_date   (display_date) UNIQUE
#  index_pictures_of_the_day_on_media_item_id  (media_item_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (media_item_id => media_items.id) ON DELETE => restrict
#
require "rails_helper"

RSpec.describe PictureOfTheDay do
  describe "factory" do
    it "has a valid factory" do
      expect(build(:picture_of_the_day)).to be_valid
      expect { create(:picture_of_the_day) }.not_to raise_error
    end

    it "has a valid factory with :today trait" do
      expect(build(:picture_of_the_day, :today)).to be_valid
    end

    it "has a valid factory with :upcoming trait" do
      expect(build(:picture_of_the_day, :upcoming)).to be_valid
    end

    it "has a valid factory with :past trait" do
      expect(build(:picture_of_the_day, :past)).to be_valid
    end

    it "has a valid factory with :with_caption trait" do
      picture = build(:picture_of_the_day, :with_caption)
      expect(picture).to be_valid
      expect(picture.caption).to be_present
    end

    it "has a valid factory with :with_description trait" do
      picture = build(:picture_of_the_day, :with_description)
      expect(picture).to be_valid
      expect(picture.description).to be_present
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:media_item) }
    it { is_expected.to belong_to(:created_by).class_name("User") }
  end

  describe "validations" do
    subject { build(:picture_of_the_day) }

    it { is_expected.to validate_presence_of(:display_date) }
    it { is_expected.to validate_uniqueness_of(:display_date) }

    context "media_item validations" do
      it "requires media_item to be an image" do
        video_item = create(:media_item, :published, :video)
        picture = build(:picture_of_the_day, media_item: video_item)

        expect(picture).not_to be_valid
        expect(picture.errors[:media_item]).to include(I18n.t("activerecord.errors.models.picture_of_the_day.attributes.media_item.must_be_image"))
      end

      it "requires media_item to be published" do
        draft_item = create(:media_item, status: "draft")
        picture = build(:picture_of_the_day, media_item: draft_item)

        expect(picture).not_to be_valid
        expect(picture.errors[:media_item]).to include(I18n.t("activerecord.errors.models.picture_of_the_day.attributes.media_item.must_be_published"))
      end

      it "allows a published image media_item" do
        published_image = create(:media_item, :published, media_type: "image")
        picture = build(:picture_of_the_day, media_item: published_image)

        expect(picture).to be_valid
      end
    end
  end

  describe "scopes" do
    describe ".past" do
      it "returns pictures with display_date in the past or today" do
        past_picture = create(:picture_of_the_day, display_date: 2.days.ago)
        today_picture = create(:picture_of_the_day, display_date: Date.current)
        upcoming_picture = create(:picture_of_the_day, display_date: 2.days.from_now)

        expect(described_class.past).to include(past_picture, today_picture)
        expect(described_class.past).not_to include(upcoming_picture)
      end

      it "orders by display_date descending" do
        old_picture = create(:picture_of_the_day, display_date: 5.days.ago)
        recent_picture = create(:picture_of_the_day, display_date: 1.day.ago)

        expect(described_class.past.first).to eq(recent_picture)
        expect(described_class.past.last).to eq(old_picture)
      end
    end

    describe ".upcoming" do
      it "returns pictures with display_date in the future" do
        past_picture = create(:picture_of_the_day, display_date: 2.days.ago)
        today_picture = create(:picture_of_the_day, display_date: Date.current)
        upcoming_picture = create(:picture_of_the_day, display_date: 2.days.from_now)

        expect(described_class.upcoming).to include(upcoming_picture)
        expect(described_class.upcoming).not_to include(past_picture, today_picture)
      end

      it "orders by display_date ascending" do
        far_future = create(:picture_of_the_day, display_date: 10.days.from_now)
        near_future = create(:picture_of_the_day, display_date: 2.days.from_now)

        expect(described_class.upcoming.first).to eq(near_future)
        expect(described_class.upcoming.last).to eq(far_future)
      end
    end

    describe ".for_date" do
      it "returns the picture for a specific date" do
        picture = create(:picture_of_the_day, display_date: Date.new(2024, 6, 15))

        expect(described_class.for_date(Date.new(2024, 6, 15))).to eq(picture)
      end

      it "returns nil when no picture exists for the date" do
        expect(described_class.for_date(Date.new(2024, 1, 1))).to be_nil
      end
    end

    describe ".recent" do
      it "returns the most recent past pictures" do
        create_list(:picture_of_the_day, 15, :past)

        expect(described_class.recent.count).to eq(10)
        expect(described_class.recent(5).count).to eq(5)
      end
    end
  end

  describe ".today" do
    it "returns the picture for today" do
      picture = create(:picture_of_the_day, :today)

      expect(described_class.today).to eq(picture)
    end

    it "returns nil when no picture exists for today" do
      create(:picture_of_the_day, display_date: 1.day.ago)

      expect(described_class.today).to be_nil
    end
  end

  describe ".current_or_most_recent" do
    it "returns today's picture when it exists" do
      today_picture = create(:picture_of_the_day, :today)
      create(:picture_of_the_day, display_date: 1.day.ago)

      expect(described_class.current_or_most_recent).to eq(today_picture)
    end

    it "returns the most recent past picture when no picture exists for today" do
      recent_picture = create(:picture_of_the_day, display_date: 1.day.ago)
      create(:picture_of_the_day, display_date: 5.days.ago)

      expect(described_class.current_or_most_recent).to eq(recent_picture)
    end

    it "returns nil when no pictures exist" do
      expect(described_class.current_or_most_recent).to be_nil
    end
  end

  describe "#display_title" do
    it "returns the caption when present" do
      picture = build(:picture_of_the_day, caption: "Custom Caption")

      expect(picture.display_title).to eq("Custom Caption")
    end

    it "returns the media_item title when caption is blank" do
      media_item = build(:media_item, title: "Media Title")
      picture = build(:picture_of_the_day, media_item: media_item, caption: nil)

      expect(picture.display_title).to eq("Media Title")
    end
  end

  describe "#display_description" do
    it "returns the description when present" do
      picture = build(:picture_of_the_day, description: "Custom description")

      expect(picture.display_description).to eq("Custom description")
    end

    it "returns the media_item description when description is blank" do
      media_item = build(:media_item, description: "Media description")
      picture = build(:picture_of_the_day, media_item: media_item, description: nil)

      expect(picture.display_description).to eq("Media description")
    end
  end

  describe "#past?" do
    it "returns true for past dates" do
      picture = build(:picture_of_the_day, display_date: 1.day.ago)

      expect(picture.past?).to be true
    end

    it "returns false for today" do
      picture = build(:picture_of_the_day, display_date: Date.current)

      expect(picture.past?).to be false
    end

    it "returns false for future dates" do
      picture = build(:picture_of_the_day, display_date: 1.day.from_now)

      expect(picture.past?).to be false
    end
  end

  describe "#today?" do
    it "returns true for today" do
      picture = build(:picture_of_the_day, display_date: Date.current)

      expect(picture.today?).to be true
    end

    it "returns false for other dates" do
      picture = build(:picture_of_the_day, display_date: 1.day.ago)

      expect(picture.today?).to be false
    end
  end

  describe "#upcoming?" do
    it "returns true for future dates" do
      picture = build(:picture_of_the_day, display_date: 1.day.from_now)

      expect(picture.upcoming?).to be true
    end

    it "returns false for today" do
      picture = build(:picture_of_the_day, display_date: Date.current)

      expect(picture.upcoming?).to be false
    end

    it "returns false for past dates" do
      picture = build(:picture_of_the_day, display_date: 1.day.ago)

      expect(picture.upcoming?).to be false
    end
  end
end
