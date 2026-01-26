module Admin
  class CollectionsController < BaseController
    before_action :set_collection, only: %i[show edit update destroy publish unpublish add_item remove_item]

    def index
      @collections = filtered_collections.includes(:collection_category, :created_by, cover_media_item: { file_attachment: :blob })
        .order(created_at: :desc).page(params[:page])
    end

    def show
    end

    def new
      @collection = Collection.new
    end

    def create
      @collection = current_user.created_collections.build(collection_params)

      if @collection.save
        redirect_to admin_collection_path(@collection), notice: t("admin.collections.messages.created")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @collection.update(collection_params)
        redirect_to admin_collection_path(@collection), notice: t("admin.collections.messages.updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @collection.destroy
      redirect_to admin_collections_path, notice: t("admin.collections.messages.deleted")
    end

    def publish
      authorize! :publish, @collection

      if @collection.publish!
        redirect_to admin_collection_path(@collection), notice: t("admin.collections.messages.published")
      else
        redirect_to admin_collection_path(@collection), alert: t("admin.collections.messages.publish_failed")
      end
    end

    def unpublish
      authorize! :unpublish, @collection

      if @collection.unpublish!
        redirect_to admin_collection_path(@collection), notice: t("admin.collections.messages.unpublished")
      else
        redirect_to admin_collection_path(@collection), alert: t("admin.collections.messages.unpublish_failed")
      end
    end

    def add_item
      media_item_id = params[:media_item_id]
      media_item = MediaItem.find(media_item_id)

      existing = @collection.collection_items.find_by(media_item: media_item)
      if existing
        render json: { message: t("admin.collections.messages.item_already_added") }, status: :unprocessable_entity
        return
      end

      max_position = @collection.collection_items.maximum(:position) || -1
      @collection.collection_items.create!(media_item: media_item, position: max_position + 1)

      render json: { success: true, html: render_to_string(partial: "collection_items", locals: { collection: @collection }) }
    end

    def remove_item
      media_item_id = params[:media_item_id]
      collection_item = @collection.collection_items.find_by!(media_item_id: media_item_id)
      collection_item.destroy!

      render json: { success: true, html: render_to_string(partial: "collection_items", locals: { collection: @collection }) }
    end

    private

    def set_collection
      @collection = Collection.find_by!(slug: params[:id])
    end

    def collection_params
      params.expect(collection: %i[name slug description position status collection_category_id cover_media_item_id])
    end

    def filtered_collections
      scope = Collection.all
      scope = scope.by_status(params[:status]) if params[:status].present?
      scope = scope.search(params[:q]) if params[:q].present?
      scope = scope.where(collection_category_id: params[:category]) if params[:category].present?
      scope
    end
  end
end
