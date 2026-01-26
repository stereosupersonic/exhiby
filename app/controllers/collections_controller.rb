class CollectionsController < ApplicationController
  allow_unauthenticated_access

  def index
    @categories = CollectionCategory.ordered.includes(collections: { cover_media_item: { file_attachment: :blob } })
    @collections_by_category = @categories.each_with_object({}) do |category, hash|
      hash[category] = category.collections.published.ordered.to_a
    end.reject { |_category, collections| collections.empty? }
  end

  def show
    @collection = Collection.published.includes(collection_category: {}).find_by!(slug: params[:slug])
    @media_items = @collection.ordered_media_items.includes(file_attachment: :blob).limit(50)
  end
end
