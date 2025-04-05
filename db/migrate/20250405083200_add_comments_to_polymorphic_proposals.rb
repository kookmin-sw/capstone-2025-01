class AddCommentsToPolymorphicProposals < ActiveRecord::Migration[8.0]
  # SQLite의 경우 comment을 지원하지 않음
  def change
    # change_column_comment :proposals, :specific_proposer_id, "Polymorphic 관계 테이블의 레코드 ID (national_assembly_people.id 또는 government_bill_sponsors.id 등)"
    # change_column_comment :proposals, :specific_proposer_type, "Polymorphic 테이블 이름 (ex. NationalAssemblyPerson, GovernmentBillSponsor 등)"
  end
end
