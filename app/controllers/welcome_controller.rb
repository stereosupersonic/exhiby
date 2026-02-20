class WelcomeController < ApplicationController
  allow_unauthenticated_access

  def index
    @recent_articles = Article.recent(3)
    @picture_of_the_day = PictureOfTheDay.current_or_most_recent
    @stats = {
      objekte: MediaItem.published.count,
      kunstschaffende: Artist.published.count,
      sammlungen: Collection.published.count,
      artikel: Article.published.count,
      bild_des_tages: PictureOfTheDay.count,
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
