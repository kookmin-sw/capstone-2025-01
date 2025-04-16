module BillsViewHelper
  def bill_steps(bill)
    base_steps = Bill.steps[0..2]
    final_step = bill.current_status_key == :discarded ?
                   Bill::STATUS_LABELS[:discarded] : Bill::STATUS_LABELS[:executed]
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
      next_step == Bill::STATUS_LABELS[:discarded] ? "step-line danger" : "step-line active"
    else
      "step-line"
    end
  end

  def text_color_class_for_status(status)
    Bill.text_color_for(status)
  end
end
