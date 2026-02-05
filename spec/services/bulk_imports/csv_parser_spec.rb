require "rails_helper"

RSpec.describe BulkImports::CsvParser do
  let(:temp_dir) { Rails.root.join("tmp", "csv_test_#{SecureRandom.hex(4)}") }

  before { FileUtils.mkdir_p(temp_dir) }
  after { FileUtils.rm_rf(temp_dir) }

  describe "#call" do
    context "with valid CSV file" do
      let(:csv_content) do
        <<~CSV
          filename,title,description,year,source,copyright,tags,artist_name,technique_name
          image1.jpg,Test Image 1,A test image,2020,Archive,Museum,History; Art,Max Mustermann,Fotografie
          image2.png,Test Image 2,Another test,2019,Collection,CC BY,Nature,,,
        CSV
      end
      let(:csv_path) { create_csv_file(csv_content) }

      it "parses CSV and returns metadata hash" do
        result = described_class.call(csv_path)

        expect(result[:success]).to be true
        expect(result[:row_count]).to eq(2)
        expect(result[:metadata]).to have_key("image1.jpg")
        expect(result[:metadata]).to have_key("image2.png")
      end

      it "extracts metadata correctly" do
        result = described_class.call(csv_path)
        metadata = result[:metadata]["image1.jpg"]

        expect(metadata[:title]).to eq("Test Image 1")
        expect(metadata[:description]).to eq("A test image")
        expect(metadata[:year]).to eq(2020)
        expect(metadata[:source]).to eq("Archive")
        expect(metadata[:copyright]).to eq("Museum")
        expect(metadata[:tags]).to eq([ "History", "Art" ])
        expect(metadata[:artist_name]).to eq("Max Mustermann")
        expect(metadata[:technique_name]).to eq("Fotografie")
      end

      it "normalizes filenames to lowercase" do
        csv_with_mixed_case = <<~CSV
          filename,title
          IMAGE1.JPG,Test
        CSV
        csv_path = create_csv_file(csv_with_mixed_case)

        result = described_class.call(csv_path)

        expect(result[:metadata]).to have_key("image1.jpg")
      end
    end

    context "with semicolon-separated tags" do
      let(:csv_content) do
        <<~CSV
          filename,title,tags
          image.jpg,Test,Tag1; Tag2; Tag3
        CSV
      end
      let(:csv_path) { create_csv_file(csv_content) }

      it "parses tags separated by semicolon" do
        result = described_class.call(csv_path)

        expect(result[:metadata]["image.jpg"][:tags]).to eq([ "Tag1", "Tag2", "Tag3" ])
      end
    end

    context "with comma-separated tags" do
      let(:csv_content) do
        <<~CSV
          filename,title,tags
          image.jpg,Test,"Tag1, Tag2, Tag3"
        CSV
      end
      let(:csv_path) { create_csv_file(csv_content) }

      it "parses tags separated by comma" do
        result = described_class.call(csv_path)

        expect(result[:metadata]["image.jpg"][:tags]).to eq([ "Tag1", "Tag2", "Tag3" ])
      end
    end

    context "with invalid year" do
      let(:csv_content) do
        <<~CSV
          filename,title,year
          image.jpg,Test,invalid
          image2.jpg,Test 2,3000
        CSV
      end
      let(:csv_path) { create_csv_file(csv_content) }

      it "returns nil for invalid years" do
        result = described_class.call(csv_path)

        expect(result[:metadata]["image.jpg"][:year]).to be_nil
        expect(result[:metadata]["image2.jpg"][:year]).to be_nil
      end
    end

    context "with empty CSV file" do
      let(:csv_path) { create_csv_file("") }

      it "returns empty metadata" do
        result = described_class.call(csv_path)

        expect(result[:success]).to be true
        expect(result[:metadata]).to be_empty
        expect(result[:row_count]).to eq(0)
      end
    end

    context "with non-existent file" do
      it "returns empty result" do
        result = described_class.call("/nonexistent/file.csv")

        expect(result[:success]).to be true
        expect(result[:metadata]).to be_empty
      end
    end

    context "with nil path" do
      it "returns empty result" do
        result = described_class.call(nil)

        expect(result[:success]).to be true
        expect(result[:metadata]).to be_empty
      end
    end

    context "with ISO-8859-1 encoded file" do
      let(:csv_path) do
        path = File.join(temp_dir, "iso.csv")
        File.write(path, "filename,title\nimage.jpg,Ümläüt".encode("ISO-8859-1"))
        path
      end

      it "handles encoding correctly" do
        result = described_class.call(csv_path)

        expect(result[:success]).to be true
        expect(result[:metadata]["image.jpg"][:title]).to include("ml")
      end
    end
  end

  private

  def create_csv_file(content)
    path = File.join(temp_dir, "test_#{SecureRandom.hex(4)}.csv")
    File.write(path, content)
    path
  end
end
