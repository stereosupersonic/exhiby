module Admin
  class PicturesOfTheDayController < BaseController
    before_action :set_picture_of_the_day, only: %i[show edit update destroy]

    def index
      @pictures_of_the_day = filter_pictures.includes(:media_item, :created_by).order(display_date: :desc)
        .paginate(page: params[:page], per_page: 25)
    end

    def show
    end

    def new
      @picture_of_the_day = PictureOfTheDay.new(display_date: Date.current)
    end

    def create
      @picture_of_the_day = PictureOfTheDay.new(picture_of_the_day_params)
      @picture_of_the_day.created_by = current_user

      if @picture_of_the_day.save
        redirect_to admin_pictures_of_the_day_path(@picture_of_the_day),
          notice: t("admin.pictures_of_the_day.messages.created")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @picture_of_the_day.update(picture_of_the_day_params)
        redirect_to admin_pictures_of_the_day_path(@picture_of_the_day),
          notice: t("admin.pictures_of_the_day.messages.updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @picture_of_the_day.destroy
      redirect_to admin_pictures_of_the_day_index_path, notice: t("admin.pictures_of_the_day.messages.deleted")
    end

    private

    def set_picture_of_the_day
      @picture_of_the_day = PictureOfTheDay.find(params[:id])
    end

    def picture_of_the_day_params
      params.expect(picture_of_the_day: %i[media_item_id display_date caption description])
    end

    def filter_pictures
      pictures = PictureOfTheDay.all

      case params[:filter]
      when "upcoming"
        pictures.upcoming
      when "past"
        pictures.past
      when "today"
        pictures.where(display_date: Date.current)
      else
        pictures
      end
    end
  end
end
