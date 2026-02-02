module MediaItems
  class SearchQuery
    attr_reader :relation, :params

    def initialize(relation = MediaItem.all, params = {})
      @relation = relation
      @params = params
    end

    def call
      @relation
        .then { |r| by_status(r) }
        .then { |r| by_media_type(r) }
        .then { |r| by_year(r) }
        .then { |r| by_search_term(r) }
    end

    private

    def by_status(relation)
      return relation if params[:status].blank?

      relation.by_status(params[:status])
    end

    def by_media_type(relation)
      media_type = params[:media_type] || params[:type]
      return relation if media_type.blank?

      relation.by_type(media_type)
    end

    def by_year(relation)
      return relation if params[:year].blank?

      relation.by_year(params[:year])
    end

    def by_search_term(relation)
      return relation if params[:q].blank?

      relation.search(params[:q])
    end
  end
end
