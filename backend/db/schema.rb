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

ActiveRecord::Schema[8.0].define(version: 2025_07_26_093041) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "locked_at"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.bigint "tenant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest", null: false
    t.datetime "last_login_at"
    t.string "last_login_ip"
    t.index "lower((email)::text), tenant_id", name: "index_admins_on_lower_email_and_tenant_id", unique: true
    t.index ["tenant_id"], name: "index_admins_on_tenant_id"
  end

  create_table "technicians", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "locked_at"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.bigint "tenant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest", null: false
    t.datetime "last_login_at"
    t.string "last_login_ip"
    t.index "lower((email)::text), tenant_id", name: "index_technicians_on_lower_email_and_tenant_id", unique: true
    t.index ["tenant_id"], name: "index_technicians_on_tenant_id"
  end

  create_table "tenants", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.string "subdomain", limit: 63, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_tenants_on_active"
    t.index ["subdomain", "active"], name: "index_tenants_on_subdomain_and_active"
    t.index ["subdomain"], name: "index_tenants_on_subdomain", unique: true
  end

  create_table "vending_machines", force: :cascade do |t|
    t.string "name"
    t.string "location"
    t.string "api_key_digest"
    t.bigint "tenant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_vending_machines_on_tenant_id"
  end

  add_foreign_key "admins", "tenants"
  add_foreign_key "technicians", "tenants"
  add_foreign_key "vending_machines", "tenants"
end
