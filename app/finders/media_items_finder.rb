class MediaItemsFinder
  include ActiveModel::Model

  FILTERS = %i[status media_type year q].freeze

  attr_accessor :relation
  attr_accessor(*FILTERS)

  def initialize(attributes = {})
    @relation = attributes.delete(:relation) || MediaItem.all
    super(attributes)
  end

  def call
    relation
      .merge(status_filter)
      .merge(media_type_filter)
      .merge(year_filter)
      .merge(search_filter)
  end

  private

  def status_filter
    status.present? ? MediaItem.by_status(status) : MediaItem.all
  end

  def media_type_filter
    media_type.present? ? MediaItem.by_type(media_type) : MediaItem.all
  end

  def year_filter
    year.present? ? MediaItem.by_year(year) : MediaItem.all
  end

  def search_filter
    q.present? ? MediaItem.search(q) : MediaItem.all
  end
end
