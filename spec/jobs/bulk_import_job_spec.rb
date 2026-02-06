require "rails_helper"

RSpec.describe BulkImportJob do
  include ActiveJob::TestHelper

  let(:user) { create(:user) }
  let(:bulk_import) { create(:bulk_import, created_by: user) }

  describe "#perform" do
    it "processes zip import" do
      allow(BulkImports::ProcessZip).to receive(:call)

      described_class.perform_now(bulk_import.id)

      expect(BulkImports::ProcessZip).to have_received(:call).with(bulk_import)
    end

    it "does not process if already processing" do
      bulk_import.update!(status: "processing")
      allow(BulkImports::ProcessZip).to receive(:call)

      described_class.perform_now(bulk_import.id)

      expect(BulkImports::ProcessZip).not_to have_received(:call)
    end

    it "does not process if already completed" do
      bulk_import.update!(status: "completed")
      allow(BulkImports::ProcessZip).to receive(:call)

      described_class.perform_now(bulk_import.id)

      expect(BulkImports::ProcessZip).not_to have_received(:call)
    end

    it "handles non-existent bulk import" do
      expect {
        described_class.perform_now(999999)
      }.not_to raise_error
    end

    it "handles unknown import type without raising" do
      bulk_import.update_column(:import_type, "unknown")
      allow(Rails.logger).to receive(:error)

      expect {
        described_class.perform_now(bulk_import.id)
      }.not_to raise_error
    end
  end

  describe "job configuration" do
    it "is queued on default queue" do
      expect(described_class.new.queue_name).to eq("default")
    end
  end
end
