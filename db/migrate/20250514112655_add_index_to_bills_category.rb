class AddIndexToBillsCategory < ActiveRecord::Migration[8.0]
  def change
    add_index :bills, :category
  end
end
