class AddUserName < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :name, :string, null: false, comment: "사용자 이름"
  end
end
