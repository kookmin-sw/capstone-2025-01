module BillsViewHelper
  def bill_steps(bill)
    base_steps = Bill.steps[0..2]
    final_step = bill.current_status_key == :discarded ?
                   BillStatus::STATUS_LABELS[:discarded] : BillStatus::STATUS_LABELS[:executed]
    base_steps + [ final_step ]
  end

  def emoji_for_status(status)
    Bill.emoji_for(status)
  end

  def css_class_for_status(status)
    Bill.css_class_for(status)
  end

  def step_line_class(bill, step, index, steps)
    current_index = steps.index(bill.current_status)
    next_step = steps[index + 1]

    if bill.current_status == next_step || current_index > index
      next_step == BillStatus::STATUS_LABELS[:discarded] ? "step-line danger" : "step-line active"
    else
      "step-line"
    end
  end

  def text_color_class_for_status(status)
    Bill.text_color_for(status)
  end


  def law_category_link(tab)
    case tab
    when "all"
      bills_path
    when "starred"
      bills_path(request.query_parameters.merge(starred: true))  # 관심법안은 독립 파라미터로 처리
    else
      current_tabs = Array(params[:tab]) - [ "all", "starred" ]

      if current_tabs.include?(tab)
        current_tabs -= [ tab ]
      else
        current_tabs << tab
      end

      current_tabs.empty? ? bills_path : bills_path(tab: current_tabs)
    end
  end
end
