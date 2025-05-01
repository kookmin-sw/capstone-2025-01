module BillViewHelper
    # 법안 카테고리
    LAW_CATEGORIES = {
        "all" => "전체",
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
    def law_category_button(tab, options = {})
        disabled = options[:disabled] || false

        # 디폴트 선택 버튼: "전체"
        selected_buttons = params[:tab] || [ "all" ]
        category_name = LAW_CATEGORIES[tab]

        if disabled
            # 비활성화된 버튼 (법안 상세페이지 태그)
            content_tag(:div, category_name, class: "#{tab}-comp", tabindex: "-1")
        else
            # 활성화된 버튼 (법안 목록페이지 버튼)
            url = tab == "all" ? bills_path : bills_path(tab: selected_law_category_buttons(tab))
            link_to url, class: "#{tab}-comp #{'active' if selected_buttons&.include?(tab)}" do
            content_tag :div, category_name, class: "law-common-text-component"
            end
        end
    end

    # 법안 카테고리 버튼 다중 선택
    def selected_law_category_buttons(tab)
        # 선택된 버튼을 배열로 관리
        selected_buttons = Array(params[:tab])

        # "전체" 버튼 클릭 시, 모든 버튼 선택 해제
        if tab == "all"
            []
        # 특정 카테고리 선택 시, "전체" 버튼 선택 해제
        else
            if selected_buttons.include?(tab)
                selected_buttons - [ tab ]
            else
                selected_buttons + [ tab ]
            end
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
