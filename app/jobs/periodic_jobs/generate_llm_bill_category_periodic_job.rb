# frozen_string_literal: true
# typed: strict

module PeriodicJobs
  class GenerateLlmBillCategoryPeriodicJob < ApplicationJob
    extend T::Sig

    queue_as :default

    MAX_RECORDS_TO_PROCESS_PER_RUN = 10
    DEFAULT_SLEEP_SECONDS = 5.0
    # TODO: 추후 어드민 등에서 설정할 수 있도록 변경
    DEFAULT_PROMPT_TEMPLATE = "bill-category"
    DEFAULT_MODEL = T.let(Settings.bill_category.model, String)

    sig { void }
    def perform
      Rails.logger.info("Starting job: fetching up to "+
                        "#{MAX_RECORDS_TO_PROCESS_PER_RUN} bills without summary")
      # 사용할 프롬프트 템플릿 조회 (없으면 예외)
      prompt = AiPromptTemplate.find_by!(name: DEFAULT_PROMPT_TEMPLATE)
      client = OpenAI::Client.new

      # 아직 카테고리 분류가 되지 않은 Bill만 가져오기
      bills = Bill.where(current_bill_category_id: nil)
                  .where.not(summary: [ nil, "" ]) # LLM 판단을 위해 주요내용 필요
                  .order(proposed_at: :desc)
                  .limit(MAX_RECORDS_TO_PROCESS_PER_RUN)
      Rails.logger.info("Bills to process: #{bills.pluck(:id).join(', ')}")

      bills.each do |bill|
        Rails.logger.info("Processing Bill id=#{bill.id}, number=#{bill.bill_number}")
        begin
          prompt_text = prompt.render_template(
            bill_title: bill.title,
            bill_content: bill.summary,
            committee: bill.committee_name
          )

          response = client.chat(
            parameters: {
              model:       DEFAULT_MODEL,
              messages:    [ { role: "user", content: prompt_text } ]
            }
          )

          content = response.dig("choices", 0, "message", "content")
          category = bill.bill_categories.create!(
            category: content,
            llm_model: DEFAULT_MODEL,
            classified_by: "llm"
          )
          Rails.logger.info("Created BillCategory id=#{category.id} for Bill id=#{bill.id}")

          sleep DEFAULT_SLEEP_SECONDS
        rescue => e
          Rails.logger.error("Error: bill_id=#{bill.id} error=#{e.message}")
          next
        end
      end
    end
  end
end
