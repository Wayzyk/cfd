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

ActiveRecord::Schema[7.2].define(version: 2025_05_06_170827) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "tenants", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "custom_fields_settings", default: {}, null: false
    t.index ["custom_fields_settings"], name: "index_tenants_on_custom_fields_settings", using: :gin
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.bigint "tenant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "custom_field_values", default: {}, null: false
    t.index ["custom_field_values"], name: "index_users_on_custom_field_values", using: :gin
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["tenant_id"], name: "index_users_on_tenant_id"
  end

  add_foreign_key "users", "tenants"
end
