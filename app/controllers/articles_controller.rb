class ArticlesController < ApplicationController
  allow_unauthenticated_access

  def index
    @articles = Article.published.by_publication_date.includes(:author)
  end

  def show
    @article = Article.published.find_by!(slug: params[:slug])
  end
end
