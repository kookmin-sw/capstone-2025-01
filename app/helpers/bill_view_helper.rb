module BillViewHelper
  include TabParamsParser

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

  def law_category_button(tab, options = {})
    disabled      = options[:disabled] || false
    context       = options[:context] || :search
    active_tabs   = Array(options[:active_tabs]) || []
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
      # 내 관심법안은 starred=true 로 독립 처리
      if tab == "starred"
        link_to bills_path(starred: true),
          class: "#{tab}-comp law-category-button law-common-text-component #{'active' if params[:starred] == 'true'}" do
            content_tag(:div, category_name, class: "law-category-text")
        end
      else
        new_tabs = selected_law_category_buttons(tab)
        link_to bills_path(tab: new_tabs),
          class: "#{tab}-comp law-category-button law-common-text-component #{'active' if parsed_tabs.include?(tab)}" do
            content_tag(:div, category_name, class: "law-category-text")
        end
      end
    end
  end

  PARTY_CATEGORIES = {
    "democratic-party" => "더불어 민주당",
    "people-power" => "국민의 힘",
    "rebuilding-korea" => "조국혁신당"
  }.freeze

  def political_party_tab(party)
    party_name = PARTY_CATEGORIES[party]
    content_tag(:div, class: "#{party}-shape") do
      content_tag(:div, party_name, class: "#{party}-text")
    end
  end
end
