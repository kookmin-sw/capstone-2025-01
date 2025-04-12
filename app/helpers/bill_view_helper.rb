module BillViewHelper
    # 법안 카테고리
    LAW_CATEGORIES = {
        "all" => "전체",
        "labor-humanrights" => "👥 근로·노동과 인권",
        "health-welfare" => "🏥 보건과 복지",
        "socialsecurity-national" => "🚔 사회안전과 국방",
        "economy-finance" => "💰 경제·재정과 공정거래",
        "industry-sciencetechnology" => "🔬 정보통신과 기술",
        "education-culture" => "🎓 교육과 문화",
        "family-genderequality" => "🏠 가정과 성평등",
        "diplomacy-unification" => "🌍 외교·통일과 국제협력",
        "land-urbandevelopment" => "🏗 국토·도시개발과 환경",
        "disaster-climate" => "🆘 재난·기후와 원자력 안전",
        "government-administration" => "🏛 정부·행정과 공공제도",
        "legislative-judicial" => "⚖ 입법·사법과 선거제도"
    }.freeze

    # 법안 카테고리 버튼
    def law_category_button(tab, options = {})
        disabled = options[:disabled] || false

        category_name = LAW_CATEGORIES[tab]

        if disabled
            # 비활성화된 버튼 (법안 상세페이지 태그)
            content_tag(:div, category_name, class: "#{tab}-comp", tabindex: "-1")
        else
            # 활성화된 버튼 (법안 목록페이지 버튼)
            link_to bills_path(tab: tab), class: "#{tab}-comp #{'active' if params[:tab] == tab}" do
            content_tag :div, category_name, class: "law-common-text-component"
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
