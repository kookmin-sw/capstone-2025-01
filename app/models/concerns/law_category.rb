module LawCategory
  # UI에 표시되고 선택 가능한 모든 카테고리,
  # "all" 및 "starred"와 같은 특수 메타 필터를 포함합니다.
  # 키는 내부적으로 사용됩니다(URL 파라미터 등).
  # 값은 표시에 사용되는 사람이 읽을 수 있는 이름입니다.
  DISPLAY_CATEGORIES = {
    "all" => "전체",
    "starred" => "⭐ 내 관심법안",
    "labor-humanrights" => "👥 근로·노동·인권",
    "health-welfare" => "🏥 보건·복지",
    "socialsecurity-national" => "🚔 교통·사회안전·국방",
    "economy-finance" => "💰 경제",
    "informationcommunication-sciencetechnology" => "🔬 정보통신·과학기술",
    "industry-agriculture" => "🏭 산업·농축수산",
    "education" => "🎓 교육",
    "culture-sports" => "🎭 문화·체육·관광",
    "family-genderequality" => "🏠 가정·성평등",
    "diplomacy-unification" => "🌍 외교·통일",
    "land-environment" => "🏗 국토·환경",
    "disaster-climate" => "🆘 재난·기후·원자력",
    "government-administration" => "🏛 정부·행정",
    "legislative-judicial" => "⚖ 입법·사법·선거제도"
  }.freeze

  # 데이터베이스에 저장될 수 있고 실제 법안 분류를 나타내는 카테고리입니다.
  # 이 목록에는 "all" 및 "starred"와 같은 메타 필터가 제외됩니다.
  # BillCategory 모델의 유효성 검사 및 데이터베이스 쿼리 구성에 사용해야 합니다.
  PERSISTABLE_CATEGORIES = DISPLAY_CATEGORIES.except("all", "starred").freeze

  # 저장 가능한 카테고리의 키 배열입니다.
  # 유효성 검사에 유용합니다 (`inclusion: { in: PERSISTABLE_CATEGORY_KEYS }`)
  PERSISTABLE_CATEGORY_KEYS = PERSISTABLE_CATEGORIES.keys.freeze

  # 저장 가능한 카테고리의 사람이 읽을 수 있는 이름 배열입니다.
  PERSISTABLE_CATEGORY_NAMES = PERSISTABLE_CATEGORIES.values.freeze
end
