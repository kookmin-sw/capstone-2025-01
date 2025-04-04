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

ActiveRecord::Schema[8.0].define(version: 2025_04_03_192557) do
  create_table "bills", force: :cascade do |t|
    t.string "title", null: false
    t.string "bill_number"
    t.text "summary"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "bill_type"
    t.string "assembly_bill_id"
    t.datetime "proposed_at"
    t.index ["assembly_bill_id"], name: "index_bills_on_assembly_bill_id", unique: true
    t.index ["bill_type"], name: "index_bills_on_bill_type"
  end

  create_table "government_bill_sponsors", force: :cascade do |t|
    t.integer "proposer_id", null: false
    t.string "ministry_name"
    t.string "department_name"
    t.string "manager_name"
    t.string "manager_contact"
    t.string "manager_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["proposer_id"], name: "index_government_bill_sponsors_on_proposer_id"
  end

  create_table "government_legislation_notices", force: :cascade do |t|
    t.string "law_card_id"
    t.integer "bill_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bill_id"], name: "index_government_legislation_notices_on_bill_id"
    t.index ["law_card_id"], name: "index_government_legislation_notices_on_law_card_id", unique: true
  end

  create_table "national_assembly_people", force: :cascade do |t|
    t.integer "proposer_id", null: false
    t.string "department_code", null: false
    t.string "member_id", null: false
    t.string "name", null: false
    t.string "english_name"
    t.string "hanja_name"
    t.string "latest_age"
    t.string "election_count"
    t.string "constituency"
    t.string "photo_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["proposer_id"], name: "index_national_assembly_people_on_proposer_id"
  end

  create_table "proposals", force: :cascade do |t|
    t.integer "bill_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "representative_proposal"
    t.integer "specific_proposer_id"
    t.string "specific_proposer_type"
    t.index ["bill_id"], name: "index_proposals_on_bill_id"
  end

  create_table "proposers", force: :cascade do |t|
    t.string "proposer_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "government_bill_sponsors", "proposers"
  add_foreign_key "government_legislation_notices", "bills"
  add_foreign_key "national_assembly_people", "proposers"
  add_foreign_key "proposals", "bills"
end
