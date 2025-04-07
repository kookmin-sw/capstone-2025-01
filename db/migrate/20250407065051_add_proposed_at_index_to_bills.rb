class AddProposedAtIndexToBills < ActiveRecord::Migration[8.0]
  def change
    add_index :bills, :proposed_at
  end
end
