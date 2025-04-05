class RemoveUnnecessaryTables < ActiveRecord::Migration[8.0]
  def change
    drop_table :bill_events, if_exists: true

    change_table :bills do |t|
      t.remove :department_id
      t.remove :public_comment_start_date
      t.remove :public_comment_end_date
    end
    drop_table :departments, if_exists: true
  end
end
