class SearchController < ApplicationController
  allow_unauthenticated_access

  def index
    @query = params[:q]
    return if @query.blank? && !params[:all].present?

    base_media = MediaItem.published.recent.includes(:media_tags, :artist, :technique, file_attachment: :blob)
    base_media = @query.present? ? base_media.search(@query) : base_media

    @media_items = base_media.limit(20)
    @articles = @query.present? ? Article.published.search(@query).limit(10) : Article.none
    @collections = @query.present? ? Collection.published.search(@query).includes(cover_media_item: { file_attachment: :blob }).limit(10) : Collection.none
    @artists = @query.present? ? Artist.published.search(@query).alphabetical.includes(profile_media_item: { file_attachment: :blob }).limit(10) : Artist.none
  end
end
