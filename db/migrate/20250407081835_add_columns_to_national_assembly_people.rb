class AddColumnsToNationalAssemblyPeople < ActiveRecord::Migration[8.0]
  def change
    add_column :national_assembly_people, :party_name, :string, comment: "소속정당"
    add_index :national_assembly_people, :party_name
    add_column :national_assembly_people, :birth_date, :string, comment: "생년월일"
    add_column :national_assembly_people, :homepage_url, :string, comment: "홈페이지URL"
    add_column :national_assembly_people, :affiliated_committee, :string, comment: "소속위원회"
  end
end
