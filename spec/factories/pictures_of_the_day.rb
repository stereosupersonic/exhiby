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
FactoryBot.define do
  factory :picture_of_the_day do
    association :media_item, :published
    association :created_by, factory: :user
    sequence(:display_date) { |n| Date.current - n.days }

    trait :today do
      display_date { Date.current }
    end

    trait :upcoming do
      sequence(:display_date) { |n| Date.current + n.days }
    end

    trait :past do
      sequence(:display_date) { |n| Date.current - (n + 1).days }
    end

    trait :with_caption do
      caption { "Custom Caption for the Day" }
    end

    trait :with_description do
      description { "Custom description for this picture of the day." }
    end
  end
end
