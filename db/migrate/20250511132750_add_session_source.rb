class AddSessionSource < ActiveRecord::Migration[8.0]
  def change
    add_column :sessions, :source, :string
  end
end
