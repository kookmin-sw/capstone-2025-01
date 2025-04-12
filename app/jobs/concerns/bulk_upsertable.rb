# frozen_string_literal: true
# typed: true


module BulkUpsertable
  extend T::Sig
  extend ActiveSupport::Concern

  sig {
    params(
      records: T::Array[T.untyped], # Array of AR objects, T.untyped for flexibility
      model_class: T.class_of(ActiveRecord::Base), # Class inheriting from AR::Base
      conflict_target: T::Array[Symbol],
      update_columns: T::Array[Symbol],
      validate: T::Boolean,
      silence: T::Boolean
    )
    .void
  }
  def bulk_upsert(records, model_class, conflict_target:, update_columns:, validate: false, silence: false)
    if records.empty?
      Rails.logger.info "No records to upsert for #{model_class.name}."
      return
    end

    Rails.logger.info "Upserting #{records.count} #{T.must(model_class.name).pluralize}..."
    # Ensure updated_at is included for updates
    columns_to_update = (update_columns.map(&:to_sym) + [ :updated_at ]).uniq
    if silence
      ActiveRecord::Base.logger.silence do
        model_class.import records,
                           on_duplicate_key_update: {
                             conflict_target: conflict_target,
                             columns: columns_to_update
                           },
                           validate: validate # Skip validations for performance by default
      end
    else
      model_class.import records,
                         on_duplicate_key_update: {
                           conflict_target: conflict_target,
                           columns: columns_to_update
                         },
                         validate: validate # Skip validations for performance by default
    end

  rescue StandardError => e
    Rails.logger.error "Bulk upsert failed for #{model_class.name}: #{e.message}\n#{e.backtrace&.first(5)&.join("\n")}"
    Kernel.raise
  end
end
