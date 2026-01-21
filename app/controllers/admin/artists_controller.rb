module Admin
  class ArtistsController < BaseController
    before_action :set_artist, only: %i[show edit update destroy publish unpublish]

    def index
      @artists = filtered_artists.includes(:created_by, profile_media_item: { file_attachment: :blob })
        .recent.page(params[:page])
    end

    def show
    end

    def new
      @artist = Artist.new
    end

    def create
      @artist = current_user.created_artists.build(artist_params)

      if @artist.save
        redirect_to admin_artist_path(@artist), notice: t("admin.artists.messages.created")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @artist.update(artist_params)
        redirect_to admin_artist_path(@artist), notice: t("admin.artists.messages.updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @artist.destroy
        redirect_to admin_artists_path, notice: t("admin.artists.messages.deleted")
      else
        redirect_to admin_artist_path(@artist), alert: t("admin.artists.messages.cannot_delete_with_media_items")
      end
    end

    def publish
      authorize! :publish, @artist

      if @artist.publish!
        redirect_to admin_artist_path(@artist), notice: t("admin.artists.messages.published")
      else
        redirect_to admin_artist_path(@artist), alert: t("admin.artists.messages.publish_failed")
      end
    end

    def unpublish
      authorize! :unpublish, @artist

      if @artist.unpublish!
        redirect_to admin_artist_path(@artist), notice: t("admin.artists.messages.unpublished")
      else
        redirect_to admin_artist_path(@artist), alert: t("admin.artists.messages.unpublish_failed")
      end
    end

    private

    def set_artist
      @artist = Artist.find_by!(slug: params[:id])
    end

    def artist_params
      params.expect(artist: %i[name slug birth_date death_date birth_place death_place
                               status published_at profile_image profile_media_item_id biography cv])
    end

    def filtered_artists
      scope = Artist.all
      scope = scope.by_status(params[:status]) if params[:status].present?
      scope = scope.search(params[:q]) if params[:q].present?
      scope
    end
  end
end
