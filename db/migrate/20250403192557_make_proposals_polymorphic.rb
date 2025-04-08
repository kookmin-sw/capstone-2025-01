class MakeProposalsPolymorphic < ActiveRecord::Migration[8.0]
  def change
    add_column :proposals, :specific_proposer_id, :integer
    add_column :proposals, :specific_proposer_type, :string

    remove_column :proposals, :proposer_id, :integer
  end
end
