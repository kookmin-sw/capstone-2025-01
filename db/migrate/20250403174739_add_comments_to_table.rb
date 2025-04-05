class AddCommentsToTable < ActiveRecord::Migration[8.0]
  # SQLite의 경우 comment을 지원하지 않음
  def change
    # change_table_comment :bills, "의안 정보를 저장하는 테이블"
    # change_column_comment :bills, :title, "의안 제목 (ex. 국민건강보험법 일부개정법률안(이병진의원 등 14인))"
    # change_column_comment :bills, :bill_number, "의안번호 (ex. 2209562) - 회기+의안번호 형식"
    # change_column_comment :bills, :assembly_bill_id, "의안 ID"
    # change_column_comment :bills, :summary, "제안이유 및 주요내용"
    # change_column_comment :bills, :bill_type, "의안 유형 (ex. 법률안, 예산안, 결의안 등)"
    # change_column_comment :bills, :proposed_at, "제안 일자"

    # change_table_comment :proposals, "Bill과 Proposer의 관계 테이블 (many-to-many)"
    # change_column_comment :proposals, :representative_proposal, "대표발의여부 (정부인 경우 null)"

    # change_table_comment :proposers, "법안 제안주체 테이블"
    # change_column_comment :proposers, :proposer_type, "제안주체 유형 (의원, 위원장, 정부, 의장, 대통령, 기타)"

    # change_table_comment :national_assembly_people, "국회의원 정보 테이블 (Proposer와 IS-A 관계)"
    # change_column_comment :national_assembly_people, :department_code, "부서코드"
    # change_column_comment :national_assembly_people, :member_id, "국회의원 식별코드"
    # change_column_comment :national_assembly_people, :name, "한글 이름"
    # change_column_comment :national_assembly_people, :english_name, "영문 이름"
    # change_column_comment :national_assembly_people, :hanja_name, "한자 이름"
    # change_column_comment :national_assembly_people, :latest_age, "마지막(최신) 국회 대수"
    # change_column_comment :national_assembly_people, :election_count, "선수(당선 횟수)"
    # change_column_comment :national_assembly_people, :constituency, "선거구"
    # change_column_comment :national_assembly_people, :photo_url, "사진 URL"

    # change_table_comment :government_bill_sponsors, "정부부처 정보 테이블 (Proposer와 IS-A 관계)"
    # change_column_comment :government_bill_sponsors, :ministry_name, "소관부처명"
    # change_column_comment :government_bill_sponsors, :department_name, "소관부서명"
    # change_column_comment :government_bill_sponsors, :manager_name, "입안자명"
    # change_column_comment :government_bill_sponsors, :manager_contact, "입안자 연락처"
    # change_column_comment :government_bill_sponsors, :manager_email, "입안자 이메일"

    # change_table_comment :government_legislation_notices, "정부입법예고 정보 테이블"
    # change_column_comment :government_legislation_notices, :law_card_id, "법안정보카드 ID"
    # change_column_comment :government_legislation_notices, :bill_id, "연결된 의안 ID (국회제출 시 연결)"
  end
end
