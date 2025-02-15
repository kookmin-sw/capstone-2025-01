class CreateBills < ActiveRecord::Migration[8.0]
  def change
    create_table :bills do |t|
      t.string :title, null: false
      t.string :bill_number, null: false
      t.string :domain
      t.text :summary
      t.text :full_text
      t.text :reason_for_revision
      t.string :current_status
      t.integer :view_count, default: 0
      t.date :public_comment_start_date
      t.date :public_comment_end_date
      t.references :department, foreign_key: true

      t.timestamps
    end
  end
end
