# == Schema Information
#
# Table name: bulk_imports
#
#  id                 :bigint           not null, primary key
#  completed_at       :datetime
#  error_messages     :jsonb            not null
#  failed_imports     :integer          default(0), not null
#  import_log         :jsonb            not null
#  import_type        :text             default("zip"), not null
#  processed_files    :integer          default(0), not null
#  started_at         :datetime
#  status             :text             default("pending"), not null
#  successful_imports :integer          default(0), not null
#  total_files        :integer          default(0), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  created_by_id      :bigint           not null
#
# Indexes
#
#  index_bulk_imports_on_created_at     (created_at)
#  index_bulk_imports_on_created_by_id  (created_by_id)
#  index_bulk_imports_on_import_type    (import_type)
#  index_bulk_imports_on_status         (status)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#
require "rails_helper"

RSpec.describe BulkImport do
  describe "factory" do
    it "has a valid factory" do
      expect(build(:bulk_import)).to be_valid
      expect { create(:bulk_import) }.not_to raise_error
    end

    it "has valid processing trait" do
      expect(build(:bulk_import, :processing)).to be_valid
    end

    it "has valid completed trait" do
      expect(build(:bulk_import, :completed)).to be_valid
    end

    it "has valid failed trait" do
      expect(build(:bulk_import, :failed)).to be_valid
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:created_by).class_name("User") }
    it { is_expected.to have_many(:media_items).dependent(:nullify) }
    it { is_expected.to have_one_attached(:file) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:import_type) }
    it { is_expected.to validate_inclusion_of(:import_type).in_array(BulkImport::IMPORT_TYPES) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_inclusion_of(:status).in_array(BulkImport::STATUSES) }
  end

  describe "scopes" do
    describe ".pending" do
      it "returns only pending imports" do
        pending_import = create(:bulk_import, status: "pending")
        create(:bulk_import, :processing)

        expect(described_class.pending).to contain_exactly(pending_import)
      end
    end

    describe ".processing" do
      it "returns only processing imports" do
        processing_import = create(:bulk_import, :processing)
        create(:bulk_import)

        expect(described_class.processing).to contain_exactly(processing_import)
      end
    end

    describe ".completed" do
      it "returns only completed imports" do
        completed_import = create(:bulk_import, :completed)
        create(:bulk_import)

        expect(described_class.completed).to contain_exactly(completed_import)
      end
    end

    describe ".failed" do
      it "returns only failed imports" do
        failed_import = create(:bulk_import, :failed)
        create(:bulk_import)

        expect(described_class.failed).to contain_exactly(failed_import)
      end
    end

    describe ".recent" do
      it "orders by created_at descending" do
        old_import = create(:bulk_import, created_at: 2.days.ago)
        new_import = create(:bulk_import, created_at: 1.day.ago)

        expect(described_class.recent).to eq([ new_import, old_import ])
      end
    end
  end

  describe "status predicates" do
    describe "#pending?" do
      it "returns true when status is pending" do
        expect(build(:bulk_import, status: "pending")).to be_pending
      end

      it "returns false when status is not pending" do
        expect(build(:bulk_import, :processing)).not_to be_pending
      end
    end

    describe "#processing?" do
      it "returns true when status is processing" do
        expect(build(:bulk_import, :processing)).to be_processing
      end
    end

    describe "#completed?" do
      it "returns true when status is completed" do
        expect(build(:bulk_import, :completed)).to be_completed
      end
    end

    describe "#failed?" do
      it "returns true when status is failed" do
        expect(build(:bulk_import, :failed)).to be_failed
      end
    end
  end

  describe "#start_processing!" do
    it "updates status to processing and sets started_at" do
      bulk_import = create(:bulk_import)

      freeze_time do
        bulk_import.start_processing!

        expect(bulk_import.status).to eq("processing")
        expect(bulk_import.started_at).to eq(Time.current)
      end
    end
  end

  describe "#complete!" do
    it "updates status to completed and sets completed_at" do
      bulk_import = create(:bulk_import, :processing)

      freeze_time do
        bulk_import.complete!

        expect(bulk_import.status).to eq("completed")
        expect(bulk_import.completed_at).to eq(Time.current)
      end
    end
  end

  describe "#fail!" do
    it "updates status to failed and sets completed_at" do
      bulk_import = create(:bulk_import, :processing)

      freeze_time do
        bulk_import.fail!("Something went wrong")

        expect(bulk_import.status).to eq("failed")
        expect(bulk_import.completed_at).to eq(Time.current)
        expect(bulk_import.error_messages).to include("Something went wrong")
      end
    end

    it "works without error message" do
      bulk_import = create(:bulk_import, :processing)
      bulk_import.fail!

      expect(bulk_import.status).to eq("failed")
    end
  end

  describe "#progress_percentage" do
    it "returns 0 when total_files is zero" do
      bulk_import = build(:bulk_import, total_files: 0, processed_files: 0)

      expect(bulk_import.progress_percentage).to eq(0)
    end

    it "calculates percentage correctly" do
      bulk_import = build(:bulk_import, total_files: 10, processed_files: 3)

      expect(bulk_import.progress_percentage).to eq(30)
    end

    it "rounds to nearest integer" do
      bulk_import = build(:bulk_import, total_files: 3, processed_files: 1)

      expect(bulk_import.progress_percentage).to eq(33)
    end
  end

  describe "#add_log_entry" do
    it "adds entry to import_log" do
      bulk_import = create(:bulk_import, import_log: [])
      entry = { filename: "test.jpg", success: true }

      bulk_import.add_log_entry(entry)

      expect(bulk_import.reload.import_log).to include(entry.stringify_keys)
    end
  end

  describe "#increment_processed!" do
    it "increments processed_files counter" do
      bulk_import = create(:bulk_import, processed_files: 0)

      expect { bulk_import.increment_processed! }
        .to change { bulk_import.reload.processed_files }.from(0).to(1)
    end
  end

  describe "#increment_successful!" do
    it "increments successful_imports counter" do
      bulk_import = create(:bulk_import, successful_imports: 0)

      expect { bulk_import.increment_successful! }
        .to change { bulk_import.reload.successful_imports }.from(0).to(1)
    end
  end

  describe "#increment_failed!" do
    it "increments failed_imports counter" do
      bulk_import = create(:bulk_import, failed_imports: 0)

      expect { bulk_import.increment_failed! }
        .to change { bulk_import.reload.failed_imports }.from(0).to(1)
    end
  end

  describe "#duration" do
    it "returns nil when started_at is not set" do
      bulk_import = build(:bulk_import, started_at: nil)

      expect(bulk_import.duration).to be_nil
    end

    it "calculates duration for completed import" do
      bulk_import = build(:bulk_import, started_at: 5.minutes.ago, completed_at: 2.minutes.ago)

      expect(bulk_import.duration).to be_within(1).of(180)
    end

    it "calculates duration for processing import" do
      bulk_import = build(:bulk_import, started_at: 3.minutes.ago, completed_at: nil)

      expect(bulk_import.duration).to be_within(1).of(180)
    end
  end
end
