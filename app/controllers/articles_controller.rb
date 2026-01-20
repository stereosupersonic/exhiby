class ArticlesController < ApplicationController
  allow_unauthenticated_access

  def index
    @articles = Article.published.by_publication_date.includes(:author).paginate(page: params[:page], per_page: 10)
  end

  def show
    @article = Article.published.find_by!(slug: params[:slug])
  end
end
