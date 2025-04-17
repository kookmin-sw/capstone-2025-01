class RemoveEditedAtFromBillSummaries < ActiveRecord::Migration[8.0]
  def change
    remove_column :bill_summaries, :edited_at, :datetime
  end
end
