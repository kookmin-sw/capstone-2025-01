class CreateBillSponsors < ActiveRecord::Migration[8.0]
  def change
    create_table :bill_sponsors do |t|
      t.references :bill, null: false, foreign_key: true
      t.references :sponsor, null: false, foreign_key: true
      t.string :sponsor_role

      t.timestamps
    end
  end
end
