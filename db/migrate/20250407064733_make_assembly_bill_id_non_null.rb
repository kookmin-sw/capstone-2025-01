class MakeAssemblyBillIdNonNull < ActiveRecord::Migration[8.0]
  def change
    change_column_null :bills, :assembly_bill_id, false
  end
end
