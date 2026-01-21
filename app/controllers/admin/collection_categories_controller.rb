module Admin
  class CollectionCategoriesController < BaseController
    before_action :set_collection_category, only: %i[edit update destroy]
    before_action :authorize_collection_category

    def index
      @collection_categories = CollectionCategory.ordered.page(params[:page])
    end

    def new
      @collection_category = CollectionCategory.new
    end

    def create
      @collection_category = CollectionCategory.new(collection_category_params)

      if @collection_category.save
        redirect_to admin_collection_categories_path, notice: t("admin.collection_categories.messages.created")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @collection_category.update(collection_category_params)
        redirect_to admin_collection_categories_path, notice: t("admin.collection_categories.messages.updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @collection_category.destroy
        redirect_to admin_collection_categories_path, notice: t("admin.collection_categories.messages.deleted")
      else
        redirect_to admin_collection_categories_path, alert: t("admin.collection_categories.messages.cannot_delete_with_collections")
      end
    end

    private

    def set_collection_category
      @collection_category = CollectionCategory.find_by!(slug: params[:id])
    end

    def authorize_collection_category
      authorize! :manage, CollectionCategory
    end

    def collection_category_params
      params.expect(collection_category: %i[name position])
    end
  end
end
