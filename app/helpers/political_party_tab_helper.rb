# 정당 탭을 생성하는 헬퍼 메서드

module PoliticalPartyTabHelper
    def political_party_tab(party)
        # 정당 정보
        parties = {
            "democratic-party" => "더불어 민주당",
            "people-power" => "국민의 힘",
            "rebuilding-korea" => "조국혁신당"
        }
        content_tag(:div, class: "#{party}-shape") do
            content_tag(:div, parties[party], class: "#{party}-text")
        end
    end
end
