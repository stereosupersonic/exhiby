require "rails_helper"
require "zip"

RSpec.describe BulkImports::ProcessZip do
  let(:user) { create(:user) }

  describe "#call" do
    context "with valid ZIP containing images" do
      let(:bulk_import) { create(:bulk_import, created_by: user) }

      before do
        attach_zip_with_images(bulk_import, 3)
      end

      it "processes all images" do
        result = described_class.call(bulk_import)

        expect(result[:success]).to be true
        expect(bulk_import.reload.status).to eq("completed")
        expect(bulk_import.total_files).to eq(3)
        expect(bulk_import.successful_imports).to eq(3)
      end

      it "creates media items for each image" do
        expect { described_class.call(bulk_import) }
          .to change(MediaItem, :count).by(3)
      end

      it "associates media items with bulk import" do
        described_class.call(bulk_import)

        expect(bulk_import.reload.media_items.count).to eq(3)
      end

      it "updates progress counters" do
        described_class.call(bulk_import)

        expect(bulk_import.reload.processed_files).to eq(3)
      end

      it "creates import log entries" do
        described_class.call(bulk_import)

        expect(bulk_import.reload.import_log.count).to eq(3)
        expect(bulk_import.import_log.all? { |e| e["success"] }).to be true
      end
    end

    context "with ZIP containing CSV metadata" do
      let(:bulk_import) { create(:bulk_import, created_by: user) }

      before do
        attach_zip_with_csv(bulk_import)
      end

      it "applies CSV metadata to images" do
        described_class.call(bulk_import)

        media_item = MediaItem.find_by(title: "CSV Title")
        expect(media_item).to be_present
        expect(media_item.description).to eq("CSV Description")
      end

      it "tracks CSV as attribute source in log" do
        described_class.call(bulk_import)

        log_entry = bulk_import.reload.import_log.find { |e| e["filename"] == "test_image.png" }
        expect(log_entry["attribute_sources"]["title"]).to eq("csv")
      end
    end

    context "when extraction fails" do
      let(:bulk_import) { create(:bulk_import, created_by: user) }

      before do
        bulk_import.file.attach(
          io: StringIO.new("invalid zip content"),
          filename: "invalid.zip",
          content_type: "application/zip"
        )
      end

      it "marks import as failed" do
        result = described_class.call(bulk_import)

        expect(result[:success]).to be false
        expect(bulk_import.reload.status).to eq("failed")
        expect(bulk_import.error_messages).to be_present
      end
    end

    context "when already processing" do
      let(:bulk_import) { create(:bulk_import, :processing, created_by: user) }

      it "continues processing" do
        attach_zip_with_images(bulk_import, 1)

        result = described_class.call(bulk_import)

        expect(result[:success]).to be true
      end
    end
  end

  private

  def attach_zip_with_images(bulk_import, count)
    temp_dir = Rails.root.join("tmp", "test_zip_#{SecureRandom.hex(4)}")
    FileUtils.mkdir_p(temp_dir)

    zip_path = File.join(temp_dir, "test.zip")
    source_image = Rails.root.join("spec/fixtures/files/test_image.png")

    Zip::File.open(zip_path, create: true) do |zipfile|
      count.times do |i|
        zipfile.add("image_#{i + 1}.png", source_image)
      end
    end

    bulk_import.file.attach(
      io: File.open(zip_path),
      filename: "test.zip",
      content_type: "application/zip"
    )

    FileUtils.rm_rf(temp_dir)
  end

  def attach_zip_with_csv(bulk_import)
    temp_dir = Rails.root.join("tmp", "test_zip_#{SecureRandom.hex(4)}")
    FileUtils.mkdir_p(temp_dir)

    zip_path = File.join(temp_dir, "test.zip")
    source_image = Rails.root.join("spec/fixtures/files/test_image.png")

    csv_content = <<~CSV
      filename,title,description
      test_image.png,CSV Title,CSV Description
    CSV

    csv_path = File.join(temp_dir, "metadata.csv")
    File.write(csv_path, csv_content)

    Zip::File.open(zip_path, create: true) do |zipfile|
      zipfile.add("test_image.png", source_image)
      zipfile.add("metadata.csv", csv_path)
    end

    bulk_import.file.attach(
      io: File.open(zip_path),
      filename: "test.zip",
      content_type: "application/zip"
    )

    FileUtils.rm_rf(temp_dir)
  end
end
