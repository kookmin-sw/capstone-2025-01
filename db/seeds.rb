# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# development
if Rails.env.development?
  department_moel = Department.find_or_create_by!(name: "고용노동부") do |dept|
    dept.contact_info = "https://www.moel.go.kr"
  end
  department_msit = Department.find_or_create_by!(name: "과학기술정보통신부") do |dept|
    dept.contact_info = "https://www.msit.go.kr"
  end

  sponsor_agency1 = Sponsor.find_or_create_by!(name: "규제개혁법무담당관 김OO") do |sponsor|
    sponsor.sponsor_type = "정부입법"
    sponsor.contact_info = "044-202-7068 | swonkim@korea.kr"
  end
  sponsor_agency2 = Sponsor.find_or_create_by!(name: "소프트웨어산업과 이OO") do |sponsor|
    sponsor.sponsor_type = "정부입법"
    sponsor.contact_info = "044-202-6337 | leebr219@msit.go.kr"
  end

  bill1 = Bill.find_or_create_by!(title: "근로기준법 일부개정안", department: department_moel) do |b|
    b.current_status = "국회제출"
    b.bill_type = "법률"
    b.summary = "근로기준법 일부를 다음과 같이 개정한다.\n제74조제7항 본문 중 “36주”를 “32주”로 한다."
    b.reason_for_revision = "조산 위험으로부터 임산부ㆍ태아의 건강을 보호하기 위하여 여성 근로자의 1일 2시간 근로시간 단축 기간을 현행 “임신 후 12주 이내 또는 36주 이후”에서 “임신 후 12주 이내 또는 32주 이후”로 확대하려는 것임."
  end
  bill2 = Bill.find_or_create_by!(title: "소프트웨어 진흥법 시행규칙 일부개정령안", department: department_msit) do |b|
    b.current_status = "입법예고"
    b.bill_type = "부령"
    b.summary = "소프트웨어프로세스 품질인증의 1등급 신설(기존: 2, 3등급 → 변경: 1, 2, 3등급)을 위해 관련 조항을 개정 (제9조제1항)"
    b.reason_for_revision = "소프트웨어프로세스 품질인증의 진입장벽 완화 및 활성화를 위해 1등급을 신설하고자 관련 조항을 개정하려는 것임."
  end

  BillSponsor.find_or_create_by!(bill: bill1, sponsor: sponsor_agency1)
  BillSponsor.find_or_create_by!(bill: bill2, sponsor: sponsor_agency2)
end
