module Admin
  class MediaTagsController < BaseController
    before_action :set_media_tag, only: [ :show, :edit, :update, :destroy ]
    before_action :authorize_admin

    def index
      @media_tags = MediaTag.alphabetical.page(params[:page])
    end

    def show
      @media_items = @media_tag.media_items.includes(:uploaded_by).recent.page(params[:page])
    end

    def new
      @media_tag = MediaTag.new
    end

    def create
      @media_tag = MediaTag.new(media_tag_params)

      if @media_tag.save
        redirect_to admin_media_tags_path, notice: t("admin.media_tags.messages.created")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @media_tag.update(media_tag_params)
        redirect_to admin_media_tags_path, notice: t("admin.media_tags.messages.updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @media_tag.destroy
      redirect_to admin_media_tags_path, notice: t("admin.media_tags.messages.deleted")
    end

    private

    def set_media_tag
      @media_tag = MediaTag.find(params[:id])
    end

    def authorize_admin
      authorize! :manage, MediaTag
    end

    def media_tag_params
      params.expect(media_tag: [ :name ])
    end
  end
end
