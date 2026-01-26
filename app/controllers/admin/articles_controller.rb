module Admin
  class ArticlesController < BaseController
    before_action :set_article, only: [ :show, :edit, :update, :destroy ]

    def index
      @articles = Article.includes(:author).order(created_at: :desc)
    end

    def show
    end

    def new
      @article = Article.new
    end

    def create
      @article = current_user.articles.build(article_params)

      if @article.save
        redirect_to admin_article_path(@article), notice: t("admin.articles.messages.created")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @article.update(article_params)
        redirect_to admin_article_path(@article), notice: t("admin.articles.messages.updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @article.destroy
      redirect_to admin_articles_path, notice: t("admin.articles.messages.deleted")
    end

    private

    def set_article
      @article = Article.find_by!(slug: params[:id])
    end

    def article_params
      params.expect(article: [ :title, :content, :status, :published_at, :cover_media_item_id ])
    end
  end
end
