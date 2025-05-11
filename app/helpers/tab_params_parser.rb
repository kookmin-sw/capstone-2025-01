module TabParamsParser
  def parsed_tabs
    raw = params[:tab]
    list =
      case raw
      when String
        raw.include?(",") ? raw.split(",") : [ raw ]
      when Array
        raw
      else
        []
      end
    list.reject { |t| t == "starred" }
  end

  def selected_law_category_buttons(tab)
    tabs = parsed_tabs
    return [] if tab == "all"
    tabs.include?(tab) ? tabs - [ tab ] : tabs + [ tab ]
  end

  alias_method :parsed_active_tabs, :parsed_tabs
end
