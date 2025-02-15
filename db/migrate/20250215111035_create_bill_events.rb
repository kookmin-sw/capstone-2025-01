class CreateBillEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :bill_events do |t|
      t.references :bill, null: false, foreign_key: true
      t.string :event_type
      t.date :event_date
      t.text :description

      t.timestamps
    end
  end
end
