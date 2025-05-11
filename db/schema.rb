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

ActiveRecord::Schema[8.0].define(version: 2025_05_11_112024) do
  create_table "ai_prompt_templates", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.text "template", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_ai_prompt_templates_on_name", unique: true
  end

  create_table "bill_details", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "jurisdiction_examination_xml"
    t.string "jurisdiction_meeting_xml"
    t.string "proc_examination_xml"
    t.string "proc_meeting_xml"
    t.string "comit_examination_xml"
    t.string "comit_meeting_xml"
    t.string "plenary_session_examination_xml"
    t.string "plenary_session_modify_xml"
    t.string "plenary_session_gov_recon_xml"
    t.datetime "bill_transferred_at"
    t.datetime "bill_promulgated_at"
    t.string "bill_promulgation_number"
    t.string "law_bon_url"
    t.string "law_title"
    t.string "comm_memo_xml"
    t.string "exhaust_xml"
    t.string "bill_gbn_cd_xml"
    t.integer "bill_id", null: false
    t.index ["bill_id"], name: "index_bill_details_on_bill_id", unique: true
  end

  create_table "bill_summaries", force: :cascade do |t|
    t.integer "bill_id", null: false
    t.text "content", null: false
    t.string "summary_type", default: "llm", null: false
    t.string "llm_model"
    t.integer "editor_id"
    t.text "edit_reason"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bill_id"], name: "index_bill_summaries_on_bill_id"
  end

  create_table "bills", force: :cascade do |t|
    t.string "title", null: false
    t.string "bill_number"
    t.text "summary"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "bill_type"
    t.string "assembly_bill_id", null: false
    t.datetime "proposed_at"
    t.string "bill_stage"
    t.string "committee_name"
    t.integer "current_bill_summary_id"
    t.boolean "auto_update_current_summary", default: true, null: false
    t.index ["assembly_bill_id"], name: "index_bills_on_assembly_bill_id", unique: true
    t.index ["bill_stage"], name: "index_bills_on_bill_stage"
    t.index ["bill_type"], name: "index_bills_on_bill_type"
    t.index ["current_bill_summary_id"], name: "index_bills_on_current_bill_summary_id"
    t.index ["proposed_at"], name: "index_bills_on_proposed_at"
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
    t.string "party_name"
    t.string "birth_date"
    t.string "homepage_url"
    t.string "affiliated_committee"
    t.index ["party_name"], name: "index_national_assembly_people_on_party_name"
    t.index ["proposer_id"], name: "index_national_assembly_people_on_proposer_id"
  end

  create_table "omni_auth_identities", force: :cascade do |t|
    t.string "uid"
    t.string "provider"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_omni_auth_identities_on_user_id"
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

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "bill_details", "bills"
  add_foreign_key "bill_summaries", "bills"
  add_foreign_key "bills", "bill_summaries", column: "current_bill_summary_id"
  add_foreign_key "government_bill_sponsors", "proposers"
  add_foreign_key "government_legislation_notices", "bills"
  add_foreign_key "national_assembly_people", "proposers"
  add_foreign_key "omni_auth_identities", "users"
  add_foreign_key "proposals", "bills"
  add_foreign_key "sessions", "users"
end
