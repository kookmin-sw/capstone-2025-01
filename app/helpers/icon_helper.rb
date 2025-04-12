# SVG 아이콘 관리를 위한 Helper 메서드

module IconHelper
  def inline_svg(filename, options = {})
    file_path = Rails.root.join("app/assets/images/icons/#{filename}.svg")
    if File.exist?(file_path)
      file = File.read(file_path)
      doc = Nokogiri::HTML::DocumentFragment.parse(file)
      svg = doc.at_css("svg")

      # 모든 fill 속성을 제거하고 currentColor로 설정
      svg.search("[fill]").each { |node| node["fill"] = "currentColor" }

      # 일반 속성 처리
      options.each do |key, value|
        next if key == :data
        svg[key.to_s] = value
      end

      # data 속성 처리
      if options[:data].present? && options[:data].is_a?(Hash)
        options[:data].each do |data_key, data_value|
          svg["data-#{data_key.to_s.dasherize}"] = data_value
        end
      end

      # debug
      if options[:debug]
        puts "SVG Element: #{svg.to_html}"
      end

      doc.to_html.html_safe
    else
      "(SVG not found: #{filename})"
    end
  end
end
