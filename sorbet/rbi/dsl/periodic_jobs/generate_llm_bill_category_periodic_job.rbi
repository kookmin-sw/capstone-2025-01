# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for dynamic methods in `PeriodicJobs::GenerateLlmBillCategoryPeriodicJob`.
# Please instead update this file by running `bin/tapioca dsl PeriodicJobs::GenerateLlmBillCategoryPeriodicJob`.


class PeriodicJobs::GenerateLlmBillCategoryPeriodicJob
  class << self
    sig do
      params(
        block: T.nilable(T.proc.params(job: PeriodicJobs::GenerateLlmBillCategoryPeriodicJob).void)
      ).returns(T.any(PeriodicJobs::GenerateLlmBillCategoryPeriodicJob, FalseClass))
    end
    def perform_later(&block); end

    sig { void }
    def perform_now; end
  end
end
