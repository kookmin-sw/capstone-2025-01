# 법안 카테고리 버튼을 생성하는 헬퍼 메서드

module LawCategoryButtonHelper
    def law_category_button(tab, options = {})
        # 법안 카테고리 정보
        categories = {
            "government-administration" => "🏛 정부·행정과 공공제도",
            "legislative-judicial" => "⚖ 입법·사법과 선거제도",
            "publicsecurity-nationaldefense" => "🚔 치안·사법과 국방",
            "economy-finance" => "💰 경제·재정과 공정거래",
            "industry-sciencetechnology" => "🔬 산업·과학기술과 정보통신",
            "land-urbandevelopment" => "🏗 국토·도시개발과 환경",
            "health-welfare" => "🏥 보건·복지와 안전망",
            "education-culture" => "🎓 교육·문화와 관광",
            "labor-humanrights" => "👥 노동·인권과 성평등",
            "diplomacy-unification" => "🌍 외교·통일과 국제협력",
            "disaster-climate" => "🆘 재난·기후와 원자력 안전"
        }

        disabled = options[:disabled] || false

        if disabled
            # 비활성화된 버튼 (법안 상세페이지 태그)
            content_tag(:div, categories[tab], class: "#{tab}-comp", tabindex: "-1")
        else
            # 활성화된 버튼 (법안 목록페이지 버튼)
            link_to bills_path(tab: tab), class: "#{tab}-comp #{'active' if params[:tab] == tab}" do
            content_tag :div, categories[tab], class: "law-common-text-component"
            end
        end
    end
end
