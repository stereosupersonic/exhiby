# == Schema Information
#
# Table name: bulk_imports
#
#  id                 :bigint           not null, primary key
#  completed_at       :datetime
#  error_messages     :jsonb            not null
#  failed_imports     :integer          default(0), not null
#  import_log         :jsonb            not null
#  import_type        :string           default("zip"), not null
#  processed_files    :integer          default(0), not null
#  started_at         :datetime
#  status             :string           default("pending"), not null
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
class BulkImport < ApplicationRecord
  STATUSES = %w[pending processing completed failed].freeze
  IMPORT_TYPES = %w[zip].freeze

  belongs_to :created_by, class_name: "User"
  has_many :media_items, dependent: :nullify

  has_one_attached :file

  validates :import_type, presence: true, inclusion: { in: IMPORT_TYPES }
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :file, presence: true, on: :create

  scope :recent, -> { order(created_at: :desc) }
  scope :pending, -> { where(status: "pending") }
  scope :processing, -> { where(status: "processing") }
  scope :completed, -> { where(status: "completed") }
  scope :failed, -> { where(status: "failed") }

  def pending?
    status == "pending"
  end

  def processing?
    status == "processing"
  end

  def completed?
    status == "completed"
  end

  def failed?
    status == "failed"
  end

  def start_processing!
    update!(
      status: "processing",
      started_at: Time.current
    )
  end

  def complete!
    update!(
      status: "completed",
      completed_at: Time.current
    )
  end

  def fail!(error_message = nil)
    new_error_messages = error_messages.dup
    new_error_messages << error_message if error_message.present?
    update!(
      status: "failed",
      completed_at: Time.current,
      error_messages: new_error_messages
    )
  end

  def progress_percentage
    return 0 if total_files.zero?

    (processed_files.to_f / total_files * 100).round
  end

  def add_log_entry(entry)
    new_log = import_log.dup
    new_log << entry
    update!(import_log: new_log)
  end

  def increment_processed!
    increment!(:processed_files)
  end

  def increment_successful!
    increment!(:successful_imports)
  end

  def increment_failed!
    increment!(:failed_imports)
  end

  def duration
    return nil unless started_at

    end_time = completed_at || Time.current
    end_time - started_at
  end
end
