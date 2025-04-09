module BillsEmojiHelper
    def status_emoji(status)
      case status
      when '접수' then '📥 '
      when '심사' then '📝 '
      when '공표', '통과' then '✅ '
      when '폐기' then '❌ '
      else '📥 '
      end
    end

    def status_css_class(status)
      case status
      when '접수' then 'status-received'
      when '심사' then 'status-reviewing'
      when '공표', '통과' then 'status-announced'
      when '폐기' then 'status-discarded'
      else 'status-received'
      end
    end
end
