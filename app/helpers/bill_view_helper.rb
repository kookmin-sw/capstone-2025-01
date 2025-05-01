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
    def law_category_button(tab, options = {})
        disabled = options[:disabled] || false
        no_link = options[:no_link] || false

        category_name = LAW_CATEGORIES[tab]

        if disabled
            # 비활성화된 버튼 (법안 상세페이지 태그)
            content_tag(:div, category_name, class: "#{tab}-comp", tabindex: "-1")
        elsif no_link
            # 메인 페이지에서는 링크 없이 div만 렌더링
            link_to "#", class: "#{tab}-comp law-category-button", data: { tab: tab, label: category_name }, onclick: "event.preventDefault();" do
            content_tag(:div, category_name, class: "#{tab}-comp law-category-button", data: { tab: tab })
            end
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
