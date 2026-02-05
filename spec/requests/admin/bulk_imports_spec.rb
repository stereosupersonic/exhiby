require "rails_helper"

RSpec.describe "Admin::BulkImports", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:editor) { create(:user, :editor) }
  let(:user) { create(:user) }

  describe "GET /admin/massenimport/:id/progress" do
    context "when authenticated as admin" do
      before { sign_in admin }

      it "returns progress data as JSON" do
        bulk_import = create(:bulk_import, :processing, created_by: admin)

        get progress_admin_bulk_import_path(bulk_import), headers: { "Accept" => "application/json" }

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include("application/json")

        json = response.parsed_body
        expect(json["status"]).to eq("processing")
        expect(json["total_files"]).to eq(bulk_import.total_files)
        expect(json["processed_files"]).to eq(bulk_import.processed_files)
        expect(json["successful_imports"]).to eq(bulk_import.successful_imports)
        expect(json["failed_imports"]).to eq(bulk_import.failed_imports)
        expect(json["progress_percentage"]).to eq(bulk_import.progress_percentage)
        expect(json["completed"]).to be false
      end

      it "returns completed: true when import is completed" do
        bulk_import = create(:bulk_import, :completed, created_by: admin)

        get progress_admin_bulk_import_path(bulk_import), headers: { "Accept" => "application/json" }

        json = response.parsed_body
        expect(json["completed"]).to be true
        expect(json["status"]).to eq("completed")
      end

      it "returns completed: true when import has failed" do
        bulk_import = create(:bulk_import, :failed, created_by: admin)

        get progress_admin_bulk_import_path(bulk_import), headers: { "Accept" => "application/json" }

        json = response.parsed_body
        expect(json["completed"]).to be true
        expect(json["status"]).to eq("failed")
      end

      it "can access other users' imports" do
        bulk_import = create(:bulk_import, created_by: user)

        get progress_admin_bulk_import_path(bulk_import), headers: { "Accept" => "application/json" }

        expect(response).to have_http_status(:ok)
      end
    end

    context "when authenticated as editor" do
      before { sign_in editor }

      it "can access any bulk import progress" do
        bulk_import = create(:bulk_import, created_by: user)

        get progress_admin_bulk_import_path(bulk_import), headers: { "Accept" => "application/json" }

        expect(response).to have_http_status(:ok)
      end
    end

    context "when authenticated as regular user" do
      before { sign_in user }

      it "can access own bulk import progress" do
        bulk_import = create(:bulk_import, created_by: user)

        get progress_admin_bulk_import_path(bulk_import), headers: { "Accept" => "application/json" }

        expect(response).to have_http_status(:ok)
      end
    end

    context "when not authenticated" do
      it "redirects to login" do
        bulk_import = create(:bulk_import, created_by: admin)

        get progress_admin_bulk_import_path(bulk_import), headers: { "Accept" => "application/json" }

        expect(response).to redirect_to(new_session_path)
      end
    end

    context "with non-existent bulk import" do
      before { sign_in admin }

      it "returns 404" do
        get progress_admin_bulk_import_path(id: 999999), headers: { "Accept" => "application/json" }

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
