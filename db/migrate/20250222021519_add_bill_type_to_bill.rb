class AddBillTypeToBill < ActiveRecord::Migration[8.0]
  def change
    add_column :bills, :bill_type, :string
    add_index :bills, :bill_type
  end
end
