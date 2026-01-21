module Admin
  class DashboardController < BaseController
    def index
      # Articles
      @articles_count = Article.count
      @published_articles_count = Article.published.count

      # Media Items
      @media_items_count = MediaItem.count
      @draft_media_items_count = MediaItem.draft.count
      @pending_media_items_count = MediaItem.pending_review.count
      @published_media_items_count = MediaItem.published.count

      # Users
      @users_count = User.count
      @active_users_count = User.active.count

      # Tags
      @tags_count = MediaTag.count

      # Artists
      @artists_count = Artist.count
      @published_artists_count = Artist.published.count

      # Recent items for quick access
      @recent_media_items = MediaItem.includes(:uploaded_by).recent.limit(5)
      @pending_review_items = MediaItem.includes(:uploaded_by).pending_review.recent.limit(5)
    end
  end
end
