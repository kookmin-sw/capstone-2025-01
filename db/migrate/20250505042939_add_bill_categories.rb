class AddBillCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :bill_categories do |t|
      t.references :bill, null: false, foreign_key: true
      t.string :category, null: false
      t.string :classified_by, null: false, default: 'llm' # 'llm', 'manual'
      t.string :llm_model
      t.integer :editor_id # FK to users, nullable
      t.datetime :edited_at
      t.text :edit_reason
      t.datetime :deleted_at # for acts_as_paranoid
      t.timestamps
    end

    add_reference :bills, :current_bill_category, foreign_key: { to_table: :bill_categories }
    add_column :bills, :category, :string # cache column for current category
    add_column :bills, :auto_update_current_category, :boolean, default: true, null: false
  end
end
