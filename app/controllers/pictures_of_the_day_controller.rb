class PicturesOfTheDayController < ApplicationController
  allow_unauthenticated_access

  def index
    @pictures_of_the_day = PictureOfTheDay.past
      .includes(media_item: { file_attachment: :blob })
      .paginate(page: params[:page], per_page: 12)
  end

  def show
    @picture_of_the_day = find_picture_by_date
    redirect_to pictures_of_the_day_path, alert: t("pictures_of_the_day.not_found") unless @picture_of_the_day
  end

  private

  def find_picture_by_date
    date = Date.parse(params[:date])
    PictureOfTheDay.for_date(date)
  rescue ArgumentError, TypeError
    nil
  end
end
