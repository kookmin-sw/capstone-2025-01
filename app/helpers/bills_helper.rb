module BillsHelper
    # 법안 진행 단계 배열 반환
    def bill_steps(bill)
      base_steps = %w[접수 검토 결정]
      final_step = bill.current_status == "중단" ? "중단" : "시행"
      base_steps + [ final_step ]
    end

    # 이모지 반환
    def emoji_for_status(status)
      Bill.emoji_for(status)
    end

    # 상태별 CSS 클래스 반환
    def css_class_for_status(status)
      Bill.css_class_for(status)
    end

    # 진행선 (step-line) 클래스 결정
    def step_line_class(bill, step, index, steps)
      current_index = steps.index(bill.current_status)
      next_step = steps[index + 1]

      if bill.current_status == next_step || current_index > index
        next_step == "중단" ? "step-line danger" : "step-line active"
      else
        "step-line"
      end
    end

    def text_color_class_for_status(status)
      BillStatus.text_color_for(status)
    end
end
