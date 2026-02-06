require "rails_helper"
require "zip"

RSpec.describe BulkImports::ZipExtractor do
  let(:extract_dir) { Rails.root.join("tmp", "test_extract_#{SecureRandom.hex(4)}") }

  after do
    FileUtils.rm_rf(extract_dir)
  end

  describe "#call" do
    context "with valid ZIP file containing images" do
      let(:zip_path) { create_test_zip([ "image1.jpg", "image2.png" ]) }

      after { File.delete(zip_path) if File.exist?(zip_path) }

      it "extracts images successfully" do
        result = described_class.call(zip_path, extract_dir)

        expect(result[:success]).to be true
        expect(result[:file_count]).to eq(2)
        expect(result[:extracted_files].map { |f| f[:filename] }).to contain_exactly("image1.jpg", "image2.png")
      end
    end

    context "with ZIP containing CSV file" do
      let(:zip_path) { create_test_zip([ "image1.jpg" ], csv: true) }

      after { File.delete(zip_path) if File.exist?(zip_path) }

      it "detects CSV file" do
        result = described_class.call(zip_path, extract_dir)

        expect(result[:success]).to be true
        expect(result[:csv_file]).to be_present
        expect(File.basename(result[:csv_file])).to eq("metadata.csv")
      end
    end

    context "with MacOS metadata files" do
      let(:zip_path) { create_test_zip_with_macos_files }

      after { File.delete(zip_path) if File.exist?(zip_path) }

      it "ignores __MACOSX directory and .DS_Store files" do
        result = described_class.call(zip_path, extract_dir)

        expect(result[:success]).to be true
        expect(result[:extracted_files].map { |f| f[:filename] }).not_to include(".DS_Store")
        expect(result[:file_count]).to eq(1)
      end
    end

    context "with path traversal attempt" do
      let(:zip_path) { create_malicious_zip_with_path_traversal }

      after { File.delete(zip_path) if File.exist?(zip_path) }

      it "does not extract files outside extract directory" do
        result = described_class.call(zip_path, extract_dir)

        expect(result[:success]).to be true
        expect(File.exist?("/etc/passwd_malicious_test")).to be false
        expect(File.exist?(File.join(extract_dir, "..", "..", "etc", "passwd"))).to be false
      end
    end

    context "with non-existent file" do
      it "raises error" do
        expect {
          described_class.call("/nonexistent/file.zip", extract_dir)
        }.to raise_error(ArgumentError, /does not exist/)
      end
    end

    context "with invalid ZIP file" do
      let(:invalid_zip) do
        path = Rails.root.join("tmp", "invalid.zip")
        File.write(path, "not a zip file")
        path
      end

      after { File.delete(invalid_zip) if File.exist?(invalid_zip) }

      it "returns error for invalid ZIP" do
        result = described_class.call(invalid_zip, extract_dir)

        expect(result[:success]).to be false
        expect(result[:error]).to include("Invalid ZIP file")
      end
    end
  end

  private

  def create_test_zip(filenames, csv: false)
    zip_path = Rails.root.join("tmp", "test_#{SecureRandom.hex(4)}.zip")

    Zip::File.open(zip_path.to_s, create: true) do |zipfile|
      filenames.each do |filename|
        zipfile.get_output_stream(filename) { |f| f.write("fake image data") }
      end

      if csv
        zipfile.get_output_stream("metadata.csv") { |f| f.write("filename,title\nimage1.jpg,Test Image\n") }
      end
    end

    zip_path.to_s
  end

  def create_test_zip_with_macos_files
    zip_path = Rails.root.join("tmp", "test_macos_#{SecureRandom.hex(4)}.zip")

    Zip::File.open(zip_path.to_s, create: true) do |zipfile|
      zipfile.get_output_stream("image.jpg") { |f| f.write("fake image data") }
      zipfile.get_output_stream("__MACOSX/._image.jpg") { |f| f.write("macos metadata") }
      zipfile.get_output_stream(".DS_Store") { |f| f.write("ds store data") }
    end

    zip_path.to_s
  end

  def create_malicious_zip_with_path_traversal
    zip_path = Rails.root.join("tmp", "test_malicious_#{SecureRandom.hex(4)}.zip")

    Zip::File.open(zip_path.to_s, create: true) do |zipfile|
      zipfile.get_output_stream("../../../etc/passwd") { |f| f.write("malicious content") }
    end

    zip_path.to_s
  end
end
