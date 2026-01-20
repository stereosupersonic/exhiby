# == Schema Information
#
# Table name: articles
#
#  id           :bigint           not null, primary key
#  published_at :datetime
#  slug         :string           not null
#  status       :string           default("draft"), not null
#  title        :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  author_id    :bigint           not null
#
# Indexes
#
#  index_articles_on_author_id     (author_id)
#  index_articles_on_published_at  (published_at)
#  index_articles_on_slug          (slug) UNIQUE
#  index_articles_on_status        (status)
#
# Foreign Keys
#
#  fk_rails_...  (author_id => users.id)
#
require "rails_helper"

RSpec.describe Article do
  describe "associations" do
    it { is_expected.to belong_to(:author).class_name("User") }
    it { is_expected.to have_rich_text(:content) }
    it { is_expected.to have_one_attached(:cover_image) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_length_of(:title).is_at_most(255) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_inclusion_of(:status).in_array(Article::STATUSES) }

    describe "slug uniqueness" do
      let!(:existing_article) { create(:article, slug: "existing-slug") }

      it "validates uniqueness of slug" do
        article = build(:article, slug: "existing-slug")
        expect(article).not_to be_valid
        expect(article.errors[:slug]).to include("ist bereits vergeben")
      end
    end
  end

  describe "scopes" do
    describe ".published" do
      let!(:published_article) { create(:article, :published) }
      let!(:published_without_date) { create(:article, status: "published", published_at: nil) }
      let!(:draft_article) { create(:article, status: "draft") }
      let!(:scheduled_article) { create(:article, :scheduled) }

      it "returns published articles with past published_at or no published_at" do
        expect(described_class.published).to contain_exactly(published_article, published_without_date)
      end
    end

    describe ".recent" do
      let!(:old_article) { create(:article, :published, published_at: 5.days.ago) }
      let!(:new_article) { create(:article, :published, published_at: 1.day.ago) }
      let!(:newest_article) { create(:article, :published, published_at: 1.hour.ago) }

      it "returns recent published articles ordered by published_at desc" do
        expect(described_class.recent(2)).to eq([ newest_article, new_article ])
      end
    end
  end

  describe "#generate_slug" do
    it "generates slug from title on create" do
      article = create(:article, title: "My Test Article", slug: nil)
      expect(article.slug).to eq("my-test-article")
    end

    it "does not overwrite existing slug on create" do
      article = create(:article, title: "My Test Article", slug: "custom-slug")
      expect(article.slug).to eq("custom-slug")
    end

    it "handles duplicate slugs by adding a counter" do
      create(:article, title: "Same Title")
      article2 = create(:article, title: "Same Title", slug: nil)
      expect(article2.slug).to eq("same-title-1")
    end

    it "updates slug when title changes" do
      article = create(:article, title: "Original Title")
      expect(article.slug).to eq("original-title")

      article.update!(title: "New Title")
      expect(article.slug).to eq("new-title")
    end

    it "does not change slug when title stays the same" do
      article = create(:article, title: "My Title")
      original_slug = article.slug

      article.update!(status: "published")
      expect(article.slug).to eq(original_slug)
    end
  end

  describe "#to_param" do
    it "returns the slug" do
      article = build(:article, slug: "test-slug")
      expect(article.to_param).to eq("test-slug")
    end
  end

  describe "#published?" do
    it "returns true for published status with past published_at" do
      article = build(:article, status: "published", published_at: 1.day.ago)
      expect(article.published?).to be true
    end

    it "returns false for draft status" do
      article = build(:article, status: "draft", published_at: 1.day.ago)
      expect(article.published?).to be false
    end

    it "returns false for published status with future published_at" do
      article = build(:article, status: "published", published_at: 1.day.from_now)
      expect(article.published?).to be false
    end

    it "returns true for published status without published_at" do
      article = build(:article, status: "published", published_at: nil)
      expect(article.published?).to be true
    end
  end

  describe "#draft?" do
    it "returns true for draft status" do
      article = build(:article, status: "draft")
      expect(article.draft?).to be true
    end

    it "returns false for published status" do
      article = build(:article, status: "published")
      expect(article.draft?).to be false
    end
  end

  describe "constants" do
    it "defines STATUSES" do
      expect(Article::STATUSES).to eq(%w[draft published])
    end
  end
end
