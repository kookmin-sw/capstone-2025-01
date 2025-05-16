module BillStatus
  extend ActiveSupport::Concern

  STATUS_KEYS = %i[received reviewing decided executed discarded].freeze

  STATUS_LABELS = {
    received:  "접수",
    reviewing: "검토",
    decided:   "결정",
    executed:  "시행",
    discarded: "중단"
  }.freeze

  STATUS_EMOJIS = {
    received:  "📥",
    reviewing: "🤔",
    decided:   "📦",
    executed:  "✅",
    discarded: "❌"
  }.freeze

  included do
    def current_status_key
      case bill_stage
      when "접수", "소관위접수"
        :received
      when "소관위심사보고", "소관위심사", "체계자구심사", "본회의부의안건", "재의요구"
        :reviewing
      when "본회의의결", "정부이송", "재의(부결)", "재의(가결)"
        :decided
      when "공포"
        :executed
      when "대안반영폐기", "수정안반영폐기", "철회"
        :discarded
      else
        :received
      end
    end

    def current_status    = STATUS_LABELS[current_status_key]
    def status_emoji      = STATUS_EMOJIS[current_status_key]
    def status_css_class  = "status-#{current_status_key}"
    def status_text_class = "text-#{current_status_key}"

    def received?   = current_status_key == :received
    def reviewing?  = current_status_key == :reviewing
    def decided?    = current_status_key == :decided
    def executed?   = current_status_key == :executed
    def rejected?   = current_status_key == :discarded
  end

  class_methods do
    def steps
      STATUS_KEYS.map { |key| STATUS_LABELS[key] }
    end

    def emoji_for(status_label)
      key = STATUS_LABELS.key(status_label)
      STATUS_EMOJIS[key] if key
    end

    def css_class_for(status_label)
      key = STATUS_LABELS.key(status_label)
      "status-#{key}" if key
    end

    def text_color_for(status_label)
      key = STATUS_LABELS.key(status_label)
      "text-#{key}" if key
    end
  end
end
