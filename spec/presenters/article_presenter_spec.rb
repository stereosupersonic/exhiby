require "rails_helper"

RSpec.describe ArticlePresenter do
  let(:article) { build(:article, :published, published_at: Time.zone.local(2024, 3, 15, 10, 30)) }
  let(:presenter) { described_class.new(article) }

  describe "#formatted_published_at" do
    context "when article has published_at" do
      it "returns formatted date in long format" do
        expect(presenter.formatted_published_at).to eq("15. März 2024 um 10:30 Uhr")
      end
    end

    context "when article has no published_at" do
      let(:article) { build(:article, published_at: nil) }

      it "returns not published message" do
        expect(presenter.formatted_published_at).to eq("Nicht veröffentlicht")
      end
    end
  end

  describe "#formatted_published_at_short" do
    context "when article has published_at" do
      it "returns formatted date in short format" do
        expect(presenter.formatted_published_at_short).to eq("15.03. 10:30")
      end
    end

    context "when article has no published_at" do
      let(:article) { build(:article, published_at: nil) }

      it "returns not published message" do
        expect(presenter.formatted_published_at_short).to eq("Nicht veröffentlicht")
      end
    end
  end

  describe "#formatted_published_at_month_year" do
    context "when article has published_at" do
      it "returns formatted date with month and year" do
        expect(presenter.formatted_published_at_month_year).to eq("März 2024")
      end
    end

    context "when article has no published_at" do
      let(:article) { build(:article, published_at: nil) }

      it "returns nil" do
        expect(presenter.formatted_published_at_month_year).to be_nil
      end
    end
  end

  describe "#status_badge_class" do
    context "when article is published" do
      let(:article) { build(:article, :published) }

      it "returns success class" do
        expect(presenter.status_badge_class).to eq("bg-success")
      end
    end

    context "when article is draft" do
      let(:article) { build(:article, status: "draft") }

      it "returns secondary class" do
        expect(presenter.status_badge_class).to eq("bg-secondary")
      end
    end
  end

  describe "#status_name" do
    it "returns translated status name for published" do
      expect(presenter.status_name).to eq("Veröffentlicht")
    end

    context "when article is draft" do
      let(:article) { build(:article, status: "draft") }

      it "returns translated status name for draft" do
        expect(presenter.status_name).to eq("Entwurf")
      end
    end
  end

  describe "#author_name" do
    it "returns author email address" do
      expect(presenter.author_name).to eq(article.author.email_address)
    end
  end

  describe "delegation" do
    it "delegates missing methods to the wrapped object" do
      expect(presenter.title).to eq(article.title)
      expect(presenter.slug).to eq(article.slug)
    end
  end
end
