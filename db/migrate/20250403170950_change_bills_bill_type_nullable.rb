class ChangeBillsBillTypeNullable < ActiveRecord::Migration[8.0]
  def change
    change_column_null :bills, :bill_type, true
  end
end
