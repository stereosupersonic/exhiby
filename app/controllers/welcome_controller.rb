class WelcomeController < ApplicationController
  allow_unauthenticated_access

  def index
    @recent_articles = Article.recent(3)
  end

  def impressum
  end

  def datenschutzerklaerung
  end
end
