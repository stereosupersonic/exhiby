class ArtistsController < ApplicationController
  allow_unauthenticated_access

  def index
    @artists = Artist.published.alphabetical.includes(profile_image_attachment: :blob)
  end

  def show
    @artist = Artist.published.find_by!(slug: params[:slug])
    @media_items = @artist.media_items.published.recent.limit(12)
  end
end
