# typed: true

class UpdateSchemaForNewDesign < ActiveRecord::Migration[8.0]
  def change
    change_table :bills do |t|
      t.string :assembly_bill_id
      t.datetime :proposed_at
      t.change :bill_number, :string # , null: false
      t.remove :domain, :full_text, :reason_for_revision, :current_status, :view_count
      t.change :bill_type, :string, null: false
    end
    add_index :bills, :assembly_bill_id, unique: true


    rename_table :sponsors, :proposers
    change_table :proposers do |t|
      t.rename :sponsor_type, :proposer_type
      t.remove :name, :party, :region, :contact_info
    end

    rename_table :bill_sponsors, :proposals
    change_table :proposals do |t|
      t.rename :sponsor_id, :proposer_id
      t.remove :sponsor_role
      t.boolean :representative_proposal
    end

    rename_index :proposals, 'index_bill_sponsors_on_sponsor_id', 'index_proposals_on_proposer_id'
    rename_index :proposals, 'index_bill_sponsors_on_bill_id', 'index_proposals_on_bill_id'

    add_foreign_key :proposals, :proposers


    create_table :national_assembly_people do |t|
      t.references :proposer, null: false, foreign_key: true
      t.string :department_code, null: false
      t.string :member_id, null: false
      t.string :name, null: false
      t.string :english_name
      t.string :hanja_name
      t.string :latest_age
      t.string :election_count
      t.string :constituency
      t.string :photo_url
      t.timestamps
    end


    create_table :government_bill_sponsors do |t|
      t.references :proposer, null: false, foreign_key: true
      t.string :ministry_name
      t.string :department_name
      t.string :manager_name
      t.string :manager_contact
      t.string :manager_email
      t.timestamps
    end

    create_table :government_legislation_notices do |t|
      t.string :law_card_id
      t.references :bill, foreign_key: true
      t.timestamps
    end
    add_index :government_legislation_notices, :law_card_id, unique: true
  end
end
