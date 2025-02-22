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

ActiveRecord::Schema[8.0].define(version: 2025_02_22_021519) do
  create_table "bill_events", force: :cascade do |t|
    t.integer "bill_id", null: false
    t.string "event_type"
    t.date "event_date"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bill_id"], name: "index_bill_events_on_bill_id"
  end

  create_table "bill_sponsors", force: :cascade do |t|
    t.integer "bill_id", null: false
    t.integer "sponsor_id", null: false
    t.string "sponsor_role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bill_id"], name: "index_bill_sponsors_on_bill_id"
    t.index ["sponsor_id"], name: "index_bill_sponsors_on_sponsor_id"
  end

  create_table "bills", force: :cascade do |t|
    t.string "title", null: false
    t.string "bill_number"
    t.string "domain"
    t.text "summary"
    t.text "full_text"
    t.text "reason_for_revision"
    t.string "current_status"
    t.integer "view_count", default: 0
    t.date "public_comment_start_date"
    t.date "public_comment_end_date"
    t.integer "department_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "bill_type"
    t.index ["bill_type"], name: "index_bills_on_bill_type"
    t.index ["department_id"], name: "index_bills_on_department_id"
  end

  create_table "departments", force: :cascade do |t|
    t.string "name", null: false
    t.string "contact_info"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sponsors", force: :cascade do |t|
    t.string "sponsor_type", null: false
    t.string "name", null: false
    t.string "party"
    t.string "region"
    t.string "contact_info"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "bill_events", "bills"
  add_foreign_key "bill_sponsors", "bills"
  add_foreign_key "bill_sponsors", "sponsors"
  add_foreign_key "bills", "departments"
end
