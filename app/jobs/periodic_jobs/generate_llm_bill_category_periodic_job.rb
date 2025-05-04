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
    end
  end
end
