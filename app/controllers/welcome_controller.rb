class WelcomeController < ApplicationController
  allow_unauthenticated_access

  def index
    @recent_articles = Article.recent(3)
    @hero_image = MediaItem.published.where(media_type: "image").order("RANDOM()").first
    @stats = {
      objekte: MediaItem.published.count,
      kunstschaffende: Artist.published.count,
      sammlungen: Collection.published.count,
      artikel: Article.published.count,
      schlagwoerter: MediaTag.count
    }
  end

  def impressum
  end

  def datenschutzerklaerung
  end

  def team
  end

  def coming_soon
  end
end
