module Admin
  class MediaItemsController < BaseController
    before_action :set_media_item, only: %i[show edit update destroy submit_for_review publish reject unpublish]
    before_action :authorize_media_item, only: %i[show edit update destroy]

    def index
      @media_items = MediaItemsFinder.new(relation: accessible_media_items, **filter_params.to_h.symbolize_keys)
        .call
        .includes(:uploaded_by, :media_tags)
        .recent
        .page(params[:page])
    end

    def search
      items = MediaItemsFinder.new(relation: accessible_media_items, **search_params.to_h.symbolize_keys)
        .call
        .limit(20)
        .includes(file_attachment: :blob)

      render json: items.map { |item|
        {
          id: item.id,
          title: item.title,
          thumbnail_url: item.file.attached? ? url_for(item.file.variant(resize_to_limit: [ 100, 100 ])) : nil
        }
      }
    end

    def extract_exif
      file = params[:file]

      unless file.present? && file.content_type.start_with?("image/")
        return render json: { error: "Invalid file" }, status: :unprocessable_entity
      end

      result = ExifMetadataExtractor.call(file.tempfile.path)

      render json: {
        suggested_values: result[:suggested_values],
        grouped_tags: result[:grouped_tags],
        all_tags: result[:all_tags],
        tags_count: result[:raw_tags_count]
      }
    end

    def show
    end

    def new
      @media_item = MediaItem.new
    end

    def create
      @media_item = build_media_item_with_exif

      if @media_item.save
        redirect_to admin_media_item_path(@media_item), notice: t("admin.media_items.messages.created")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      update_media_item_with_exif

      if @media_item.save
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
      params.expect(media_item: %i[title description media_type year source technique_id
                                   copyright license file tag_list artist_id])
    end

    def media_item_params_without_file
      params.expect(media_item: %i[title description media_type year source technique_id
                                   copyright license tag_list artist_id])
    end

    def uploaded_file
      params.dig(:media_item, :file)
    end

    def build_media_item_with_exif
      if uploaded_file.present?
        MediaItem.build_with_file(
          file: uploaded_file,
          uploaded_by: current_user,
          **media_item_params_without_file
        )
      else
        current_user.uploaded_media_items.build(media_item_params)
      end
    end

    def update_media_item_with_exif
      @media_item.assign_attributes(media_item_params_without_file)

      if uploaded_file.present?
        @media_item.attach_and_extract_exif(uploaded_file)
      end
    end

    def filter_params
      params.permit(:status, :media_type, :year, :q)
    end

    def search_params
      search = params.permit(:status, :type, :q).to_h.symbolize_keys
      search[:media_type] = search.delete(:type).presence || "image"
      search
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
