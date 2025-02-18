class ChangeBillNumberToNullable < ActiveRecord::Migration[8.0]
  def change
    change_column_null :bills, :bill_number, true
  end
end
