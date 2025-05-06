module BillViewHelper
    # 법안 카테고리
    LAW_CATEGORIES = {
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

    # 법안 카테고리 버튼
    # context: :search => 검색창 태그 방식
    # context: :list => 링크 이동 방식 (팀원 방식)
    def law_category_button(tab, options = {})
      disabled     = options[:disabled] || false
      context      = options[:context] || :search
      active_tabs  = Array(options[:active_tabs]) || []
      category_name = LAW_CATEGORIES[tab]
      return "" unless category_name

      if disabled
        content_tag(:div, category_name, class: "#{tab}-comp", tabindex: "-1")

      elsif context == :search
        link_to "#",
          class: "#{tab}-comp law-category-button law-common-text-component #{'active' if active_tabs.include?(tab)}",
          data: { tab: tab, label: category_name },
          onclick: "event.preventDefault();" do
            content_tag(:div, category_name, class: "law-category-text")
        end

      elsif context == :list
        new_tabs = selected_law_category_buttons(tab)
        link_to bills_path(tab: new_tabs),
          class: "#{tab}-comp law-category-button law-common-text-component #{'active' if Array(params[:tab]).include?(tab)}" do
            content_tag(:div, category_name, class: "law-category-text")
        end
      end
    end

    # 목록 페이지 등에서 버튼 클릭 시, 다음 상태의 URL 계산
    # 누르면 추가/제거되도록 토글 로직 포함
    def selected_law_category_buttons(tab)
      selected_buttons = Array(params[:tab])

      if tab == "all"
        []  # 전체 버튼 누르면 모두 해제
      else
        if selected_buttons.include?(tab)
          selected_buttons - [ tab ]  # 선택 해제
        else
          selected_buttons + [ tab ]  # 새로 추가
        end
      end
    end

    # 현재 어떤 탭들이 선택되어 있는지 뷰에서 사용할 수 있도록 반환
    # 검색창, 뷰 등에서 active 클래스 처리용
    def parsed_active_tabs
      case params[:tab]
      when Array
        params[:tab]
      when String
        params[:tab].include?(",") ? params[:tab].split(",") : [ params[:tab] ]
      else
        []
      end
    end

    # 정당 카테고리
    PARTY_CATEGORIES = {
      "democratic-party" => "더불어 민주당",
      "people-power" => "국민의 힘",
      "rebuilding-korea" => "조국혁신당"
    }.freeze

    # 정당 카테고리 탭
    def political_party_tab(party)
      party_name = PARTY_CATEGORIES[party]

      content_tag(:div, class: "#{party}-shape") do
        content_tag(:div, party_name, class: "#{party}-text")
      end
    end
end
