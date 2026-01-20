module Admin
  class DashboardController < BaseController
    def index
      @articles_count = Article.count
      @published_articles_count = Article.published.count
    end
  end
end
