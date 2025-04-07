class UpdateBills < ActiveRecord::Migration[8.0]
  def change
    add_column :bills, :bill_stage, :string, comment: "심사진행상태"
    add_index :bills, :bill_stage
    add_column :bills, :committee_name, :string, comment: "소관위원회"
  end
end
