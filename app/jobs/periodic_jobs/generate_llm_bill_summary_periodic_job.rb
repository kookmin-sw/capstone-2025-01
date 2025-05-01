# frozen_string_literal: true
# typed: strict

module PeriodicJobs
  class GenerateLlmBillSummaryPeriodicJob < ApplicationJob
    extend T::Sig

    queue_as :default

    MAX_RECORDS_TO_PROCESS_PER_RUN = 10
    DEFAULT_SLEEP_SECONDS = 5.0
    # TODO: 추후 어드민 등에서 설정할 수 있도록 변경
    DEFAULT_PROMPT_TEMPLATE = "bill-summary"
    DEFAULT_MODEL = T.let(Settings.bill_summary.model, String)

    sig { void }
    def perform
      Rails.logger.info("Starting job: fetching up to "+
                        "#{MAX_RECORDS_TO_PROCESS_PER_RUN} bills without summary")
      # 사용할 프롬프트 템플릿 조회 (없으면 예외)
      prompt = AiPromptTemplate.find_by!(name: DEFAULT_PROMPT_TEMPLATE)
      client = OpenAI::Client.new

      # 아직 요약이 생성되지 않은 Bill만 가져오기
      bills = Bill.where(current_bill_summary_id: nil)
                  .where.not(summary: [ nil, "" ])
                  .order(proposed_at: :desc)
                  .limit(MAX_RECORDS_TO_PROCESS_PER_RUN)
      Rails.logger.info("Bills to process: #{bills.pluck(:id).join(', ')}")

      bills.each do |bill|
        Rails.logger.info("Processing Bill id=#{bill.id}, number=#{bill.bill_number}")
        begin
          prompt_text = prompt.render_template(
            title:   bill.title,
            summary: bill.summary
          )

          response = client.chat(
            parameters: {
              model:       DEFAULT_MODEL,
              messages:    [ { role: "user", content: prompt_text } ]
            }
          )

          content = response.dig("choices", 0, "message", "content")
          summary = bill.bill_summaries.create!(
            content:   content,
            llm_model: DEFAULT_MODEL,
            summary_type: "llm"
          )
          Rails.logger.info("Created BillSummary id=#{summary.id} for Bill id=#{bill.id}")
          # callback으로 current_bill_summary_id는 자동 갱신됨

          sleep DEFAULT_SLEEP_SECONDS
        rescue => e
          Rails.logger.error("Error: bill_id=#{bill.id} error=#{e.message}")
          next
        end
      end
      Rails.logger.info("Finished job: processed #{bills.size} bills")
    end
  end
end
