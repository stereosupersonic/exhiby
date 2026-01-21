# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_01_21_111818) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "articles", force: :cascade do |t|
    t.bigint "author_id", null: false
    t.datetime "created_at", null: false
    t.datetime "published_at"
    t.string "slug", null: false
    t.string "status", default: "draft", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_articles_on_author_id"
    t.index ["published_at"], name: "index_articles_on_published_at"
    t.index ["slug"], name: "index_articles_on_slug", unique: true
    t.index ["status"], name: "index_articles_on_status"
  end

  create_table "artists", force: :cascade do |t|
    t.date "birth_date"
    t.string "birth_place"
    t.datetime "created_at", null: false
    t.bigint "created_by_id", null: false
    t.date "death_date"
    t.string "death_place"
    t.string "name", null: false
    t.bigint "profile_media_item_id"
    t.datetime "published_at"
    t.string "slug", null: false
    t.string "status", default: "draft", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_artists_on_created_by_id"
    t.index ["profile_media_item_id"], name: "index_artists_on_profile_media_item_id"
    t.index ["published_at"], name: "index_artists_on_published_at"
    t.index ["slug"], name: "index_artists_on_slug", unique: true
    t.index ["status"], name: "index_artists_on_status"
  end

  create_table "media_items", force: :cascade do |t|
    t.bigint "artist_id"
    t.string "copyright"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "license"
    t.string "media_type", null: false
    t.datetime "published_at"
    t.datetime "reviewed_at"
    t.bigint "reviewed_by_id"
    t.string "source"
    t.string "status", default: "draft", null: false
    t.datetime "submitted_at"
    t.bigint "technique_id"
    t.string "technique_legacy"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "uploaded_by_id", null: false
    t.integer "year"
    t.index ["artist_id"], name: "index_media_items_on_artist_id"
    t.index ["media_type"], name: "index_media_items_on_media_type"
    t.index ["published_at"], name: "index_media_items_on_published_at"
    t.index ["reviewed_by_id"], name: "index_media_items_on_reviewed_by_id"
    t.index ["status"], name: "index_media_items_on_status"
    t.index ["technique_id"], name: "index_media_items_on_technique_id"
    t.index ["uploaded_by_id"], name: "index_media_items_on_uploaded_by_id"
    t.index ["year"], name: "index_media_items_on_year"
  end

  create_table "media_taggings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "media_item_id", null: false
    t.bigint "media_tag_id", null: false
    t.datetime "updated_at", null: false
    t.index ["media_item_id", "media_tag_id"], name: "index_media_taggings_on_media_item_id_and_media_tag_id", unique: true
    t.index ["media_item_id"], name: "index_media_taggings_on_media_item_id"
    t.index ["media_tag_id"], name: "index_media_taggings_on_media_tag_id"
  end

  create_table "media_tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "media_items_count", default: 0
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_media_tags_on_name", unique: true
    t.index ["slug"], name: "index_media_tags_on_slug", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "techniques", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_techniques_on_name", unique: true
    t.index ["position"], name: "index_techniques_on_position"
    t.index ["slug"], name: "index_techniques_on_slug", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "activated_at"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "deactivated_at"
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.string "role", default: "user", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_users_on_active"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "articles", "users", column: "author_id"
  add_foreign_key "artists", "media_items", column: "profile_media_item_id"
  add_foreign_key "artists", "users", column: "created_by_id"
  add_foreign_key "media_items", "artists"
  add_foreign_key "media_items", "techniques"
  add_foreign_key "media_items", "users", column: "reviewed_by_id"
  add_foreign_key "media_items", "users", column: "uploaded_by_id"
  add_foreign_key "media_taggings", "media_items"
  add_foreign_key "media_taggings", "media_tags"
  add_foreign_key "sessions", "users"
end
