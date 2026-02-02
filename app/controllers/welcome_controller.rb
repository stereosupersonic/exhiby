class WelcomeController < ApplicationController
  allow_unauthenticated_access

  def index
    @recent_articles = Article.recent(3)
    @picture_of_the_day = PictureOfTheDay.current_or_most_recent
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
