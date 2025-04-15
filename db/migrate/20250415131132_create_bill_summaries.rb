class CreateBillSummaries < ActiveRecord::Migration[8.0]
  def change
    create_table :bill_summaries do |t|
      t.references :bill, null: false, foreign_key: true
      t.text :content, null: false
      t.string :summary_type, null: false, default: 'llm' # 'llm', 'manual'
      t.string :llm_model
      t.integer :editor_id # FK to users, nullable
      t.datetime :edited_at
      t.text :edit_reason
      t.datetime :deleted_at # for acts_as_paranoid
      t.timestamps
    end

    add_reference :bills, :current_bill_summary, foreign_key: { to_table: :bill_summaries }
    add_column :bills, :auto_update_current_summary, :boolean, default: true, null: false
  end
end
