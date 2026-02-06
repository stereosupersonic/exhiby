module Admin
  class BulkImportsController < BaseController
    before_action :set_bulk_import, only: %i[show destroy progress]
    before_action :authorize_bulk_import, only: %i[show destroy]

    def index
      @bulk_imports = accessible_bulk_imports
        .recent
        .page(params[:page])
    end

    def new
      @bulk_import = BulkImport.new
    end

    def create
      @bulk_import = current_user.bulk_imports.build(bulk_import_params)

      if @bulk_import.save
        BulkImportJob.perform_later(@bulk_import.id)
        redirect_to admin_bulk_import_path(@bulk_import), notice: t("admin.bulk_imports.messages.created")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def show
      @presenter = BulkImportPresenter.new(@bulk_import)
    end

    def destroy
      @bulk_import.destroy
      redirect_to admin_bulk_imports_path, notice: t("admin.bulk_imports.messages.deleted")
    end

    def progress
      render json: {
        status: @bulk_import.status,
        total_files: @bulk_import.total_files,
        processed_files: @bulk_import.processed_files,
        successful_imports: @bulk_import.successful_imports,
        failed_imports: @bulk_import.failed_imports,
        progress_percentage: @bulk_import.progress_percentage,
        completed: @bulk_import.completed? || @bulk_import.failed?
      }
    end

    private

    def set_bulk_import
      @bulk_import = BulkImport.find(params[:id])
    end

    def authorize_bulk_import
      authorize! :manage, @bulk_import
    end

    def bulk_import_params
      params.expect(bulk_import: %i[file import_type])
    end

    def accessible_bulk_imports
      if current_user.admin? || current_user.editor?
        BulkImport.all
      else
        current_user.bulk_imports
      end
    end
  end
end
