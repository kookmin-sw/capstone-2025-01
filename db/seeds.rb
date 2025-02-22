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
  department = Department.find_or_create_by!(name: "고용노동부") do |dept|
    dept.contact_info = "https://www.moel.go.kr"
  end

  sponsor_agency = Sponsor.find_or_create_by!(name: "규제개혁법무담당관 김OO") do |sponsor|
    sponsor.sponsor_type = "정부입법"
    sponsor.contact_info = "044-202-7068 | swonkim@korea.kr"
  end

  bill = Bill.find_or_create_by!(title: "근로기준법 일부개정안", department: department) do |b|
    b.current_status = "국회제출"
    b.bill_type = "법률"
    b.summary = "근로기준법 일부를 다음과 같이 개정한다.\n제74조제7항 본문 중 “36주”를 “32주”로 한다."
    b.reason_for_revision = "조산 위험으로부터 임산부ㆍ태아의 건강을 보호하기 위하여 여성 근로자의 1일 2시간 근로시간 단축 기간을 현행 “임신 후 12주 이내 또는 36주 이후”에서 “임신 후 12주 이내 또는 32주 이후”로 확대하려는 것임."
  end

  BillSponsor.find_or_create_by!(bill: bill, sponsor: sponsor_agency)
end
