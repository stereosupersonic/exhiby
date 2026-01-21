module MediaItemsHelper
  def available_years
    years = MediaItem.where.not(year: nil).distinct.pluck(:year).sort.reverse
    years.presence || [ Time.current.year ]
  end
end
