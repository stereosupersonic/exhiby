require "rails_helper"

RSpec.describe BulkImportPresenter do
  let(:user) { create(:user) }
  let(:bulk_import) { create(:bulk_import, created_by: user) }
  let(:presenter) { described_class.new(bulk_import) }

  describe "#status_badge_class" do
    it "returns correct class for pending" do
      bulk_import.status = "pending"
      expect(presenter.status_badge_class).to eq("bg-secondary")
    end

    it "returns correct class for processing" do
      bulk_import.status = "processing"
      expect(presenter.status_badge_class).to eq("bg-info")
    end

    it "returns correct class for completed" do
      bulk_import.status = "completed"
      expect(presenter.status_badge_class).to eq("bg-success")
    end

    it "returns correct class for failed" do
      bulk_import.status = "failed"
      expect(presenter.status_badge_class).to eq("bg-danger")
    end
  end

  describe "#status_name" do
    it "returns translated status name" do
      bulk_import.status = "pending"
      expect(presenter.status_name).to eq(I18n.t("bulk_import_statuses.pending"))
    end
  end

  describe "#source_badge_class" do
    it "returns correct class for csv" do
      expect(presenter.source_badge_class("csv")).to eq("bg-primary")
    end

    it "returns correct class for exif" do
      expect(presenter.source_badge_class("exif")).to eq("bg-info")
    end

    it "returns correct class for filename" do
      expect(presenter.source_badge_class("filename")).to eq("bg-secondary")
    end
  end

  describe "#source_name" do
    it "returns translated source name" do
      expect(presenter.source_name("csv")).to eq(I18n.t("bulk_import_sources.csv"))
    end
  end

  describe ".source_badge_class" do
    it "returns correct class for csv" do
      expect(described_class.source_badge_class("csv")).to eq("bg-primary")
    end

    it "returns correct class for exif" do
      expect(described_class.source_badge_class("exif")).to eq("bg-info")
    end

    it "returns correct class for filename" do
      expect(described_class.source_badge_class("filename")).to eq("bg-secondary")
    end

    it "returns default class for unknown source" do
      expect(described_class.source_badge_class("unknown")).to eq("bg-secondary")
    end
  end

  describe ".source_name" do
    it "returns translated source name" do
      expect(described_class.source_name("csv")).to eq(I18n.t("bulk_import_sources.csv"))
    end
  end

  describe "#creator_name" do
    it "returns email of creator" do
      expect(presenter.creator_name).to eq(user.email_address)
    end
  end

  describe "#formatted_created_at" do
    it "returns formatted date" do
      expect(presenter.formatted_created_at).to be_present
    end
  end

  describe "#formatted_started_at" do
    it "returns nil when not started" do
      bulk_import.started_at = nil
      expect(presenter.formatted_started_at).to be_nil
    end

    it "returns formatted date when started" do
      bulk_import.started_at = 1.hour.ago
      expect(presenter.formatted_started_at).to be_present
    end
  end

  describe "#formatted_completed_at" do
    it "returns nil when not completed" do
      bulk_import.completed_at = nil
      expect(presenter.formatted_completed_at).to be_nil
    end

    it "returns formatted date when completed" do
      bulk_import.completed_at = 1.hour.ago
      expect(presenter.formatted_completed_at).to be_present
    end
  end

  describe "#formatted_duration" do
    it "returns nil when no duration" do
      bulk_import.started_at = nil
      expect(presenter.formatted_duration).to be_nil
    end

    it "returns seconds for short duration" do
      bulk_import.started_at = 30.seconds.ago
      bulk_import.completed_at = Time.current
      expect(presenter.formatted_duration).to include("Sekunde")
    end

    it "returns minutes for medium duration" do
      bulk_import.started_at = 3.minutes.ago
      bulk_import.completed_at = Time.current
      expect(presenter.formatted_duration).to include("Minute")
    end

    it "returns hours for long duration" do
      bulk_import.started_at = 2.hours.ago
      bulk_import.completed_at = Time.current
      expect(presenter.formatted_duration).to include("Stunde")
    end
  end

  describe "#file_info" do
    it "returns file info when attached" do
      expect(presenter.file_info).to include("test_import.zip")
    end

    it "returns nil when not attached" do
      bulk_import.file.detach
      expect(presenter.file_info).to be_nil
    end
  end

  describe "#progress_bar_class" do
    it "returns striped animated for processing" do
      bulk_import.status = "processing"
      expect(presenter.progress_bar_class).to include("progress-bar-striped")
    end

    it "returns success for completed" do
      bulk_import.status = "completed"
      expect(presenter.progress_bar_class).to eq("bg-success")
    end

    it "returns danger for failed" do
      bulk_import.status = "failed"
      expect(presenter.progress_bar_class).to eq("bg-danger")
    end
  end

  describe "#log_entries" do
    let(:bulk_import) { create(:bulk_import, :completed, created_by: user) }

    it "returns LogEntry objects" do
      expect(presenter.log_entries).to all(be_a(described_class::LogEntry))
    end

    it "returns correct count" do
      expect(presenter.log_entries.count).to eq(5)
    end
  end

  describe "#successful_log_entries" do
    let(:bulk_import) { create(:bulk_import, :completed, created_by: user) }

    it "returns only successful entries" do
      expect(presenter.successful_log_entries.count).to eq(4)
      expect(presenter.successful_log_entries).to all(be_success)
    end
  end

  describe "#failed_log_entries" do
    let(:bulk_import) { create(:bulk_import, :completed, created_by: user) }

    it "returns only failed entries" do
      expect(presenter.failed_log_entries.count).to eq(1)
      expect(presenter.failed_log_entries.first).not_to be_success
    end
  end

  describe "#duplicate_log_entries" do
    let(:bulk_import) do
      create(:bulk_import, :completed, created_by: user, import_log: [
        { filename: "image1.jpg", success: true, media_item_id: 1 },
        { filename: "duplicate.jpg", success: false, duplicate: true, existing_media_item_id: 1 },
        { filename: "error.jpg", success: false, errors: [ "Some error" ] }
      ])
    end

    it "returns only duplicate entries" do
      expect(presenter.duplicate_log_entries.count).to eq(1)
      expect(presenter.duplicate_log_entries.first.filename).to eq("duplicate.jpg")
    end
  end

  describe BulkImportPresenter::LogEntry do
    let(:entry_data) do
      {
        filename: "test.jpg",
        success: true,
        media_item_id: 123,
        attribute_sources: { title: "csv" },
        processed_at: Time.current.iso8601
      }
    end
    let(:entry) { described_class.new(entry_data) }

    describe "#filename" do
      it "returns filename" do
        expect(entry.filename).to eq("test.jpg")
      end
    end

    describe "#success?" do
      it "returns true for successful entry" do
        expect(entry).to be_success
      end

      it "returns false for failed entry" do
        failed_entry = described_class.new(success: false)
        expect(failed_entry).not_to be_success
      end
    end

    describe "#media_item_id" do
      it "returns media item id" do
        expect(entry.media_item_id).to eq(123)
      end
    end

    describe "#attribute_sources" do
      it "returns attribute sources hash" do
        expect(entry.attribute_sources).to eq("title" => "csv")
      end
    end

    describe "#errors" do
      it "returns empty array when no errors" do
        expect(entry.errors).to eq([])
      end

      it "returns errors array" do
        failed_entry = described_class.new(errors: [ "Error 1", "Error 2" ])
        expect(failed_entry.errors).to eq([ "Error 1", "Error 2" ])
      end
    end

    describe "#processed_at" do
      it "returns time object" do
        expect(entry.processed_at).to be_a(Time)
      end

      it "returns nil when not set" do
        entry_without_time = described_class.new({})
        expect(entry_without_time.processed_at).to be_nil
      end
    end

    describe "#duplicate?" do
      it "returns true for duplicate entry" do
        duplicate_entry = described_class.new(duplicate: true, success: false)
        expect(duplicate_entry).to be_duplicate
      end

      it "returns false for non-duplicate entry" do
        expect(entry).not_to be_duplicate
      end
    end

    describe "#existing_media_item_id (for duplicates)" do
      it "returns existing media item id for duplicates" do
        duplicate_entry = described_class.new(duplicate: true, existing_media_item_id: 456)
        expect(duplicate_entry.existing_media_item_id).to eq(456)
      end
    end
  end
end
