module Admin
  class MediaItemsController < BaseController
    before_action :set_media_item, only: [ :show, :edit, :update, :destroy, :submit_for_review, :publish, :reject, :unpublish ]
    before_action :authorize_media_item, only: [ :show, :edit, :update, :destroy ]

    def index
      @media_items = filtered_media_items.includes(:uploaded_by, :media_tags).recent.page(params[:page])
    end

    def show
    end

    def new
      @media_item = MediaItem.new
    end

    def create
      @media_item = current_user.uploaded_media_items.build(media_item_params)

      if @media_item.save
        redirect_to admin_media_item_path(@media_item), notice: t("admin.media_items.messages.created")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @media_item.update(media_item_params)
        redirect_to admin_media_item_path(@media_item), notice: t("admin.media_items.messages.updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @media_item.destroy
      redirect_to admin_media_items_path, notice: t("admin.media_items.messages.deleted")
    end

    def submit_for_review
      authorize! :submit_for_review, @media_item

      if @media_item.submit_for_review!
        redirect_to admin_media_item_path(@media_item), notice: t("admin.media_items.messages.submitted_for_review")
      else
        redirect_to admin_media_item_path(@media_item), alert: t("admin.media_items.messages.submit_failed")
      end
    end

    def publish
      authorize! :publish, @media_item

      if @media_item.publish!(current_user)
        redirect_to admin_media_item_path(@media_item), notice: t("admin.media_items.messages.published")
      else
        redirect_to admin_media_item_path(@media_item), alert: t("admin.media_items.messages.publish_failed")
      end
    end

    def reject
      authorize! :reject, @media_item

      if @media_item.reject!(current_user)
        redirect_to admin_media_item_path(@media_item), notice: t("admin.media_items.messages.rejected")
      else
        redirect_to admin_media_item_path(@media_item), alert: t("admin.media_items.messages.reject_failed")
      end
    end

    def unpublish
      authorize! :unpublish, @media_item

      if @media_item.unpublish!
        redirect_to admin_media_item_path(@media_item), notice: t("admin.media_items.messages.unpublished")
      else
        redirect_to admin_media_item_path(@media_item), alert: t("admin.media_items.messages.unpublish_failed")
      end
    end

    private

    def set_media_item
      @media_item = MediaItem.find(params[:id])
    end

    def authorize_media_item
      authorize! :manage, @media_item
    end

    def media_item_params
      params.expect(media_item: [ :title, :description, :media_type, :year, :source, :technique,
                                 :copyright, :license, :file, :tag_list, :artist_id ])
    end

    def filtered_media_items
      scope = accessible_media_items
      scope = scope.by_status(params[:status]) if params[:status].present?
      scope = scope.by_type(params[:media_type]) if params[:media_type].present?
      scope = scope.by_year(params[:year]) if params[:year].present?
      scope = scope.search(params[:q]) if params[:q].present?
      scope
    end

    def accessible_media_items
      if current_user.admin? || current_user.editor?
        MediaItem.all
      else
        current_user.uploaded_media_items
      end
    end
  end
end
