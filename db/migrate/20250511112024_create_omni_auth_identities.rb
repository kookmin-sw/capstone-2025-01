class CreateOmniAuthIdentities < ActiveRecord::Migration[8.0]
  def change
    create_table :omni_auth_identities do |t|
      t.string :uid
      t.string :provider
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
