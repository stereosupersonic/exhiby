module Admin
  class TechniquesController < BaseController
    before_action :set_technique, only: %i[edit update destroy]
    before_action :authorize_technique

    def index
      @techniques = Technique.ordered.page(params[:page])
    end

    def new
      @technique = Technique.new
    end

    def create
      @technique = Technique.new(technique_params)

      if @technique.save
        redirect_to admin_techniques_path, notice: t("admin.techniques.messages.created")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @technique.update(technique_params)
        redirect_to admin_techniques_path, notice: t("admin.techniques.messages.updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @technique.destroy
      redirect_to admin_techniques_path, notice: t("admin.techniques.messages.deleted")
    end

    private

    def set_technique
      @technique = Technique.find_by!(slug: params[:id])
    end

    def authorize_technique
      authorize! :manage, Technique
    end

    def technique_params
      params.expect(technique: %i[name position])
    end
  end
end
