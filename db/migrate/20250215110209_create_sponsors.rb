class CreateSponsors < ActiveRecord::Migration[8.0]
  def change
    create_table :sponsors do |t|
      t.string :sponsor_type, null: false
      t.string :name, null: false
      t.string :party
      t.string :region
      t.string :contact_info

      t.timestamps
    end
  end
end
