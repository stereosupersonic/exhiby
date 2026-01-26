# == Schema Information
#
# Table name: articles
#
#  id                  :bigint           not null, primary key
#  published_at        :datetime
#  slug                :string           not null
#  status              :string           default("draft"), not null
#  title               :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  author_id           :bigint           not null
#  cover_media_item_id :bigint
#
# Indexes
#
#  index_articles_on_author_id            (author_id)
#  index_articles_on_cover_media_item_id  (cover_media_item_id)
#  index_articles_on_published_at         (published_at)
#  index_articles_on_slug                 (slug) UNIQUE
#  index_articles_on_status               (status)
#
# Foreign Keys
#
#  fk_rails_...  (author_id => users.id)
#  fk_rails_...  (cover_media_item_id => media_items.id)
#
FactoryBot.define do
  factory :article do
    sequence(:title) { |n| "Test Article #{n}" }
    content { "This is the article content." }
    status { "draft" }
    association :author, factory: :user

    trait :published do
      status { "published" }
      published_at { 1.day.ago }
    end

    trait :scheduled do
      status { "published" }
      published_at { 1.day.from_now }
    end

    trait :with_content do
      content { "<p>This is rich text content with <strong>bold</strong> and <em>italic</em> text.</p>" }
    end
  end
end
