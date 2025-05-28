module BillViewHelper
  include TabParamsParser

  # 법안 목록페이지: 법안 카테고리 버튼 생성
  def law_category_button(tab, options = {})
    disabled      = options[:disabled] || false
    context       = options[:context] || :search
    active_tabs   = Array(options[:active_tabs]) || []
    category_name = LawCategory::DISPLAY_CATEGORIES[tab]
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
  # 법안 목록페이지: 정당 카테고리 버튼 생성
  def political_party_tab(party)
    party_name = PARTY_CATEGORIES[party]
    content_tag(:div, class: "#{party}-shape") do
      content_tag(:div, party_name, class: "#{party}-text")
    end
  end

  # 법안 목록페이지: 법안 카드 내용(ai 요약 제목 / 법안 요약)
  def bill_summary_content(bill)
    if bill.current_bill_summary.present?
      bill.current_bill_summary.parse_heading_section
    else
      summary_text(bill.summary)
    end
  end

  private

  def summary_text(summary)
    return "" if summary.blank?

    summary.gsub(/\A(?:제안이유 및 주요내용|제안이유|대안의 제안이유)[:\s]*/, "")
  end
end
