class AddUniqueConstraintToBillDetailsBillId < ActiveRecord::Migration[8.0]
  def change
    # Remove the existing non-unique index
    remove_index :bill_details, name: "index_bill_details_on_bill_id", if_exists: true

    # Add a unique index to bill_id
    add_index :bill_details, :bill_id, unique: true, name: "index_bill_details_on_bill_id"
  end
end
