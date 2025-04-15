module BillStatus
    extend ActiveSupport::Concern

    included do
      # 현재 상태 문자열 반환
      def current_status
        case bill_stage
        when "소관위접수" then "접수"
        when "소관위심사중", "법사위심사중" then "검토"
        when "의결", "국회통과", "법사위의결" then "결정"
        when "공포", "시행" then "시행"
        when "폐기" then "중단"
        else "접수"
        end
      end

      # 현재 상태에 해당하는 이모지
      def status_emoji
        self.class.emoji_for(current_status)
      end

      # 현재 상태에 해당하는 CSS 클래스
      def status_css_class
        self.class.css_class_for(current_status)
      end

      # 상태별 Boolean 메서드
      def received?  = current_status == "접수"
      def reviewing? = current_status == "검토"
      def decided?   = current_status == "결정"
      def executed?  = current_status == "시행"
      def rejected?  = current_status == "중단"
    end

    class_methods do
      # 전체 진행 단계 배열
      def steps
        %w[접수 검토 결정 시행 중단]
      end

      # 이모지 반환
      def emoji_for(status)
        {
          "접수" => "📥",
          "검토" => "🤔",
          "결정" => "📦",
          "시행" => "✅",
          "중단" => "❌"
        }[status] || "📥"
      end

      # 상태별 CSS 클래스 반환
      def css_class_for(status)
        {
          "접수" => "status-received",
          "검토" => "status-reviewing",
          "결정" => "status-decided",
          "시행" => "status-executed",
          "중단" => "status-discarded"
        }[status] || "status-received"
      end
    end
end
