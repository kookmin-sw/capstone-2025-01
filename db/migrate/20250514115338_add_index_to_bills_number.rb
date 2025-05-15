class AddIndexToBillsNumber < ActiveRecord::Migration[8.0]
  def change
    add_index :bills, :bill_number
  end
end
