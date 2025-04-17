# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#

# 공통 데이터

# 기본 법안 요약 프롬프트 생성
AiPromptTemplate.find_or_create_by!(name: "bill-summary") do |template|
  template.description = "의안 요약용 프롬프트"
  template.template = <<~PROMPT
[역할] 당신은 복잡한 법률 정보를 20대 일반인을 대상으로 이해하기 쉽게, 특히 SNS 콘텐츠처럼 인포그래픽 형태의 텍스트로 변환하는 전문가입니다.
[목표] 주어진 법안의 제·개정 이유와 주요 내용을 분석하여 '변경 이유', '전후 비교', 마무리를 포함한 시각적으로 구조화된 정보로 재구성해주세요.

[출력 형식] 다음 구조를 정확히 따라주세요:
1. 제목
- 법안의 핵심을 1~2문장으로 요약 (예: 연장근로 방식이 달라져요. 근로시간은 더 자유롭게, 보상은 휴가처럼!)
- 쉽고 직관적이게
- 의견을 제시하지 않고 법안 내용에 명확히 제시된 부분을 가공.
- 사회의 법안과 관련된 내용이므로 너무 가벼운 말투를 사용하지 않고 신뢰감을 주는 문장과 단어를 사용.
2. "###📌 왜 바뀌나요?" 섹션
- 개정 이유를 한 줄로 정리 (예: 연장근로 관리 방식을 유연하게 바꿔서 근로자의 자유로운 일정 조정을 보장하려는 개정안이에요.)
3. "###⏳ 개정 전과 후, 무엇이 달라지나요?" 섹션.
 - 개정 전과 개정 후를 표를 사용하여 직관적으로 비교
 - 결론적으로 개인적인 의견으로 판단하지 않고, 법안 내용에서 바뀌는 중점을 한 줄로 정리.
 - 마지막 한 줄 정리에서: 원문에서 인용한 내용일지라도 확신하는 말투를 쓰지 말고 "~하려는 것이에요.", "~할 것이에요." 형태 사용
4. "###✨마무리" 섹션
 - 법안의 장점과 단점을 드러내지 않고, 법안이 통과되면 예상되는 상황을 한 줄로 정리.
 - 독자가 의견을 공유하도록 유도 (예: "여러분은 어떻게 생각하시나요?")

[해야 할 것]
- 모든 문장은 친근하고 대화체로 작성해주세요.(예: "~해요", "~네요" 형태 사용)
- 어렵거나 일상 대화에서 많이 사용하지 않는 단어는 일상적인 표현으로 바꿔주세요.
- 문장에서 중요한 단어는 **굵게** 강조 (1문장에 2개 이하)- Q&A는 국민이 가장 궁금해할 내용으로 구성해주세요.
- 정치적 편향성 없이 균형있게 작성해주세요.
- 법안 내용에 없는 정보는 추측하지 말고 "이 부분은 명확하지 않습니다"라고 표시하고 원문을 그대로 인용해주세요.

다음 법안 내용을 분석해 위 형식에 맞게 재구성해주세요:

[법안 제목]
{{title}}

[법안 제안이유 및 주요내용]
{{summary}}
  PROMPT
end


# 개발환경 데이터
if Rails.env.development?
  # 제안주체 생성
  %w[의원 위원장 정부 의장 대통령 기타].each do |type|
    Proposer.find_or_create_by!(proposer_type: type)
  end

  # 정부부처 제안주체 생성
  gov_proposer = Proposer.find_by(proposer_type: "정부")
  gov_sponsor1 = GovernmentBillSponsor.find_or_create_by!(
    ministry_name: "농림축산식품부",
    department_name: "농림축산식품부",
    manager_name: "송하정",
    manager_contact: "044-200-6753",
    manager_email: "hjsong@korea.kr"
  ) do |sponsor|
    sponsor.proposer_id = gov_proposer.id
  end
  gov_sponsor2 = GovernmentBillSponsor.find_or_create_by!(
    ministry_name: "공정거래위원회",
    department_name: "기업거래정책과",
    manager_name: "이경희",
    manager_contact: "044-200-4948",
    manager_email: "kftc_1366@mail.go.kr"
  ) do |sponsor|
    sponsor.proposer_id = gov_proposer.id
  end

  # 정부입법 의안 생성
  gov_bill1 = Bill.find_or_create_by!(bill_number: "2209143") do |b|
    b.title = "양봉산업의 육성 및 지원에 관한 법률 일부개정법률안"
    b.bill_type = "법률안"
    b.assembly_bill_id = "ARC_O2N5Y0K3V1H9W2Z1F1C2K2U6Q8N7E8"
    b.summary = "제안이유 및 주요내용 지방자치단체 수행 사무에 관한 규범을 지방자치단체가 자기 책임하에 자율적으로 정할 수 있도록 자치입법권을 확대하기 위하여 지방자치단체가 밀원식물(蜜原植物)*의 조성에 필요한 사항을 해당 지방자치단체의 조례로 정할 수 있도록 하려는 것임. * 밀원식물(蜜原植物): 꿀벌이 꽃꿀, 꽃가루와 수액의 수집을 위하여 찾아가는 식물로서 농림축산식품부령으로 정하는 식물"
    b.proposed_at = Date.new(2025, 3, 20)
    b.committee_name = "농림축산식품해양수산위원회"
    b.bill_stage = "소관위접수"
  end
  gov_bill2 = Bill.find_or_create_by!(bill_number: "2207522") do |b|
    b.title = "하도급거래 공정화에 관한 법률 일부개정법률안(정부)"
    b.bill_type = "법률안"
    b.assembly_bill_id = "ARC_D2L5R0Z1E1D5O1A1B0X2P5Z7E1S4O5"
    b.summary = "제안이유 및 주요내용 행정기관 소속 위원회를 효율적으로 운영하기 위하여 설치ㆍ운영 필요성이 줄어든 상습법위반사업자명단공표심의위원회를 폐지하고, 그 기능을 공정거래위원회가 수행하도록 하려는 것임."
    b.proposed_at = Date.new(2025, 1, 15)
    b.committee_name = "정무위원회"
    b.bill_stage = "소관위접수"
  end

  Proposal.find_or_create_by!(bill: gov_bill1, specific_proposer: gov_sponsor1)
  Proposal.find_or_create_by!(bill: gov_bill2, specific_proposer: gov_sponsor2)

  BillDetail.find_or_create_by!(bill_id: gov_bill1.id) do |detail|
    detail.jurisdiction_examination_xml = "<committeeName>농림축산식품해양수산위원회</committeeName><presentDt/><procDt/><procResultCd/><submitDt>2025-03-21</submitDt>"
    detail.law_title = "양봉산업의 육성 및 지원에 관한 법률"
  end
  BillDetail.find_or_create_by!(bill_id: gov_bill2.id) do |detail|
    detail.jurisdiction_examination_xml = "<committeeName>정무위원회</committeeName><presentDt/><procDt/><procResultCd/><submitDt>2025-01-16</submitDt>"
    detail.law_title = "하도급거래 공정화에 관한 법률"
    detail.comm_memo_xml = "<commMemo>비용추계요구서 제출됨.</commMemo>"
  end

  # 국회의원 제안주체 생성
  assembly_proposer = Proposer.find_by(proposer_type: "의원")

  assembly_proposer1 = NationalAssemblyPerson.find_or_create_by!(
    department_code: "9771327",
    member_id: "3094",
    name: "김문수",
    english_name: "KIM MOONSOO",
    hanja_name: "金文洙",
    constituency: "전남 순천시광양시곡성군구례군갑",
    election_count: "초선",
    latest_age: "22",
    photo_url: "http://www.assembly.go.kr/photo/9771327.jpg",
    party_name: "더불어민주당",
    birth_date: "19681001",
    homepage_url: "https://www.assembly.go.kr/members/22nd/KIMMOONSOO",
    affiliated_committee: "교육위원회,예산결산특별위원회"
  ) do |member|
    member.proposer_id = assembly_proposer.id
  end
  assembly_proposer2 = NationalAssemblyPerson.find_or_create_by!(
    department_code: "9771326",
    member_id: "3000",
    name: "김동아",
    english_name: "KIM DONGAH",
    hanja_name: "金東我",
    constituency: "서울 서대문구갑",
    election_count: "초선",
    latest_age: "22",
    photo_url: "http://www.assembly.go.kr/photo/9771326.jpg",
    party_name: "더불어민주당",
    birth_date: "19871030",
    homepage_url: "https://www.assembly.go.kr/members/22nd/KIMDONGAH",
    affiliated_committee: "산업통상자원중소벤처기업위원회"
  ) do |member|
    member.proposer_id = assembly_proposer.id
  end
  assembly_proposer3 = NationalAssemblyPerson.find_or_create_by!(
    department_code: "9771336",
    member_id: "3206",
    name: "김우영",
    english_name: "KIM WOOYOUNG",
    hanja_name: "金宇榮",
    constituency: "서울 은평구을",
    election_count: "초선",
    latest_age: "22",
    photo_url: "http://www.assembly.go.kr/photo/9771336.jpg",
    party_name: "더불어민주당",
    birth_date: "19690805",
    homepage_url: "https://www.assembly.go.kr/members/22nd/KIMWOOYOUNG",
    affiliated_committee: "과학기술정보방송통신위원회"
  ) do |member|
    member.proposer_id = assembly_proposer.id
  end
  assembly_proposer4 = NationalAssemblyPerson.find_or_create_by!(
    department_code: "9771366",
    member_id: "2533",
    name: "박지원",
    english_name: "PARK JIEWON",
    hanja_name: "朴智元",
    constituency: "전남 해남군완도군진도군",
    election_count: "5선",
    latest_age: "22",
    photo_url: "http://www.assembly.go.kr/photo/9771366.jpg",
    party_name: "더불어민주당",
    birth_date: "19420605",
    homepage_url: "https://www.assembly.go.kr/members/22nd/PARKJIEWON",
    affiliated_committee: "법제사법위원회,정보위원회"
  ) do |member|
    member.proposer_id = assembly_proposer.id
  end
  assembly_proposer5 = NationalAssemblyPerson.find_or_create_by!(
    department_code: "9771369",
    member_id: "3166",
    name: "박해철",
    english_name: "PARK HAECHEOL",
    hanja_name: "朴海澈",
    constituency: "경기 안산시병",
    election_count: "초선",
    latest_age: "22",
    photo_url: "http://www.assembly.go.kr/photo/9771369.jpg",
    party_name: "더불어민주당",
    birth_date: "19650914",
    homepage_url: "https://www.assembly.go.kr/members/22nd/PARKHAECHEOL",
    affiliated_committee: "환경노동위원회"
  ) do |member|
    member.proposer_id = assembly_proposer.id
  end
  assembly_proposer6 = NationalAssemblyPerson.find_or_create_by!(
    department_code: "9771376",
    member_id: "3095",
    name: "서미화",
    english_name: "SEO MIHWA",
    hanja_name: "徐美和",
    constituency: "비례대표",
    election_count: "초선",
    latest_age: "22",
    photo_url: "http://www.assembly.go.kr/photo/9771376.jpg",
    party_name: "더불어민주당",
    birth_date: "19671106",
    homepage_url: "https://www.assembly.go.kr/members/22nd/SEOMIHWA",
    affiliated_committee: "국회운영위원회,보건복지위원회"
  ) do |member|
    member.proposer_id = assembly_proposer.id
  end
  assembly_proposer7 = NationalAssemblyPerson.find_or_create_by!(
    department_code: "9771269",
    member_id: "3056",
    name: "이수진",
    english_name: "LEE SOOJIN",
    hanja_name: "李壽珍",
    constituency: "경기 성남시중원구",
    election_count: "재선",
    latest_age: "22",
    photo_url: "http://www.assembly.go.kr/photo/9771269.jpg",
    party_name: "더불어민주당",
    birth_date: "19690514",
    homepage_url: "https://www.assembly.go.kr/members/22nd/LEESOOJIN",
    affiliated_committee: "12.29여객기참사진상규명과피해자및유가족의피해구제를위한특별위원회,보건복지위원회"
  ) do |member|
    member.proposer_id = assembly_proposer.id
  end
  assembly_proposer8 = NationalAssemblyPerson.find_or_create_by!(
    department_code: "9771115",
    member_id: "3075",
    name: "이용선",
    english_name: "LEE YONGSUN",
    hanja_name: "李庸瑄",
    constituency: "서울 양천구을",
    election_count: "재선",
    latest_age: "22",
    photo_url: "http://www.assembly.go.kr/photo/9771115.jpg",
    party_name: "더불어민주당",
    birth_date: "19580212",
    homepage_url: "https://www.assembly.go.kr/members/22nd/LEEYONGSUN",
    affiliated_committee: "외교통일위원회"
  ) do |member|
    member.proposer_id = assembly_proposer.id
  end
  assembly_proposer9 = NationalAssemblyPerson.find_or_create_by!(
    department_code: "9771412",
    member_id: "3157",
    name: "이재관",
    english_name: "LEE JAEKWAN",
    hanja_name: "李在官",
    constituency: "충남 천안시을",
    election_count: "초선",
    latest_age: "22",
    photo_url: "http://www.assembly.go.kr/photo/9771412.jpg",
    party_name: "더불어민주당",
    birth_date: "19650301",
    homepage_url: "https://www.assembly.go.kr/members/22nd/LEEJAEKWAN",
    affiliated_committee: "산업통상자원중소벤처기업위원회"
  ) do |member|
    member.proposer_id = assembly_proposer.id
  end
  assembly_proposer10 = NationalAssemblyPerson.find_or_create_by!(
    department_code: "9771182",
    member_id: "3270",
    name: "한준호",
    english_name: "HAN JUNHO",
    hanja_name: "韓俊鎬",
    constituency: "경기 고양시을",
    election_count: "재선",
    latest_age: "22",
    photo_url: "http://www.assembly.go.kr/photo/9771182.jpg",
    party_name: "더불어민주당",
    birth_date: "19740220",
    homepage_url: "https://www.assembly.go.kr/members/22nd/HANJUNHO",
    affiliated_committee: "국토교통위원회"
  ) do |member|
    member.proposer_id = assembly_proposer.id
  end
  assembly_proposer11 = NationalAssemblyPerson.find_or_create_by!(
    department_code: "9771456",
    member_id: "3172",
    name: "허성무",
    english_name: "HUH SUNGMOO",
    hanja_name: "許成武",
    constituency: "경남 창원시성산구",
    election_count: "초선",
    latest_age: "22",
    photo_url: "http://www.assembly.go.kr/photo/9771456.jpg",
    party_name: "더불어민주당",
    birth_date: "19631029",
    homepage_url: "https://www.assembly.go.kr/members/22nd/HUHSUNGMOO",
    affiliated_committee: "2025 아시아태평양경제협력체(APEC) 정상회의 지원 특별위원회,산업통상자원중소벤처기업위원회,예산결산특별위원회"
  ) do |member|
    member.proposer_id = assembly_proposer.id
  end

  # 의원 발의 의안 생성
  assembly_bill1 = Bill.find_or_create_by!(bill_number: "2209530") do |b|
    b.title = "갈등관리 및 공론화에 관한 법률안(김문수의원 등 11인)"
    b.bill_type = "법률안"
    b.assembly_bill_id = "PRC_T2U5C0C3B1B3A0A9Z3H9H1F3G7E3F7"
    b.summary = "제안이유 사회구조가 변화하고 가치, 이해관계가 다원화됨에 따라 공공정책의 추진과정에서 다양한 형태의 갈등이 분출되고 있음. 이에 중앙행정기관의 갈등을 예방하고 해결하기 위한 역할 및 절차에 관한 사항을 규정하여 중앙행정기관의 갈등관리 능력을 향상시키고, 사회변화에 부합하는 참여적 의사결정의 제도적 기반을 마련하려는 것임. 주요내용 가. 갈등 예방과 해결의 원칙(안 제4조부터 제7조까지) 중앙행정기관의 장으로 하여금 공공정책을 수립ㆍ추진할 때 이해관계인의 신뢰를 확보하도록 하고, 이해관계인 등의 실질적인 참여가 보장되도록 하며, 공공정책을 통하여 달성하려는 공익과 이에 상충되는 다른 공익 또는 사익을 비교ㆍ형량하도록 하고, 공공정책 관련 정보를 공개하고 공유하도록 하는 등 갈등 예방과 해결의 원칙을 규정함. 나. 갈등관리 종합시책의 수립(안 제8조) 중앙행정기관의 장으로 하여금 갈등의 예방과 해결 능력을 강화하기 위하여 갈등관리가 필요한 공공정책의 선정 및 관리 계획에 관한 사항 등이 포함된 갈등관리 종합시책을 매년 수립ㆍ추진하도록 함. 다. 갈등관리심의위원회의 설치ㆍ운영(안 제9조부터 제11조까지) 1) 소관 사무에 대한 갈등의 예방과 해결에 관련된 사항을 심의하기 위하여 중앙행정기관에 갈등관리심의위원회를 설치하되, 조정ㆍ지원 등 업무를 담당하는 중앙행정기관은 갈등관리심의위원회를 설치하지 아니할 수 있도록 함. 2) 갈등관리심의위원회는 위원장 1명을 포함하여 15명 이내의 위원으로 구성하고, 공무원이 아닌 위원이 전체 위원의 과반수가 되도록 함. 3) 갈등관리심의위원회 위원이 중립적이고 공정한 입장에서 활동하도록 함. 4) 중앙행정기관의 장으로 하여금 정당한 사유가 있는 경우를 제외하고는 갈등관리심의위원회의 심의 결과를 갈등의 예방과 해결 과정에 성실히 반영하도록 함. 라. 공론화대상선정위원회의 설치ㆍ운영(안 제15조부터 제21조까지) 1) 공론화 대상 의제를 선정하고, 공론화 제도를 공정하고 체계적으로 운영하기 위하여 국무총리 소속으로 공론화대상선정위원회를 둠. 2) 공론화대상선정위원회는 위원장 1명을 포함하여 11명 이상 15명 이하의 위원으로 구성하도록 하고, 공론화대상선정위원회 위원은 공무원이 아닌 사람 중에서 국무총리가 위촉하도록 하며, 공론화대상선정위원회 위원장은 공론화대상선정위원회 위원 중에서 호선하도록 함. 3) 공론화대상선정위원회 위원이 안건이 본인이나 친족과 직접적인 이해관계가 있는 경우 등에는 그 안건의 심의ㆍ의결에서 제척되거나 스스로 회피하도록 함. 마. 공론화위원회의 설치ㆍ운영(안 제23조부터 제26조까지) 1) 공론화를 공정하고 효율적으로 진행하기 위하여 공론화대상선정위원회에서 공론화 실시 대상으로 의결된 의제별로 공론화위원회를 둠. 2) 공론화위원회는 위원장 1명을 포함하여 6명 이상 10명 이하의 위원으로 구성하도록 하고, 공론화위원회 위원장은 공론화대상선정위원회 위원 중에서 공론화대상선정위원회 위원장이 위촉하도록 하며, 공론화위원회 위원장이 아닌 위원은 공무원이 아닌 사람 중에서 공론화대상선정위원회의 의결을 거쳐 공론화위원회 위원장이 위촉하도록 함. 3) 공론화위원회의 운영기간은 6개월의 범위에서 공론화위원회의 의결을 거쳐 공론화위원회 위원장이 정하되, 공론화위원회의 의결을 거쳐 6개월의 범위에서 1회 연장할 수 있도록 함."
    b.proposed_at = Date.new(2025, 4, 1)
  end

  Proposal.find_or_create_by!(bill: assembly_bill1, specific_proposer: assembly_proposer1, representative_proposal: true)
  Proposal.find_or_create_by!(bill: assembly_bill1, specific_proposer: assembly_proposer2, representative_proposal: false)
  Proposal.find_or_create_by!(bill: assembly_bill1, specific_proposer: assembly_proposer3, representative_proposal: false)
  Proposal.find_or_create_by!(bill: assembly_bill1, specific_proposer: assembly_proposer4, representative_proposal: false)
  Proposal.find_or_create_by!(bill: assembly_bill1, specific_proposer: assembly_proposer5, representative_proposal: false)
  Proposal.find_or_create_by!(bill: assembly_bill1, specific_proposer: assembly_proposer6, representative_proposal: false)
  Proposal.find_or_create_by!(bill: assembly_bill1, specific_proposer: assembly_proposer7, representative_proposal: false)
  Proposal.find_or_create_by!(bill: assembly_bill1, specific_proposer: assembly_proposer8, representative_proposal: false)
  Proposal.find_or_create_by!(bill: assembly_bill1, specific_proposer: assembly_proposer9, representative_proposal: false)
  Proposal.find_or_create_by!(bill: assembly_bill1, specific_proposer: assembly_proposer10, representative_proposal: false)
  Proposal.find_or_create_by!(bill: assembly_bill1, specific_proposer: assembly_proposer11, representative_proposal: false)

  BillDetail.find_or_create_by!(bill_id: assembly_bill1.id) do |detail|
    detail.jurisdiction_examination_xml = "<committeeName>정무위원회</committeeName><presentDt/><procDt/><procResultCd/><submitDt>2025-04-02</submitDt>"
    detail.law_title = "갈등관리 및 공론화에 관한 법률"
    detail.comm_memo_xml = "<commMemo>비용추계요구서 제출됨.</commMemo>"
  end

  # TODO(@greenstar1151): 추후 정부입법예고 생성 필요
end
