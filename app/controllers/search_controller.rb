class SearchController < ApplicationController
  allow_unauthenticated_access

  def index
    @query = params[:q]
    return if @query.blank?

    @media_items = MediaItem.published.search(@query).recent.includes(:media_tags, :artist, :technique, file_attachment: :blob).limit(20)
    @articles = Article.published.search(@query).limit(10)
    @collections = Collection.published.search(@query).includes(cover_media_item: { file_attachment: :blob }).limit(10)
    @artists = Artist.published.search(@query).alphabetical.includes(profile_media_item: { file_attachment: :blob }).limit(10)
  end
end
