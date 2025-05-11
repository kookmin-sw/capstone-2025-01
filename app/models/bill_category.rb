# frozen_string_literal: true

class BillCategory < ApplicationRecord
  acts_as_paranoid

  belongs_to :bill
  belongs_to :editor, class_name: "User", optional: true

  validates :category, presence: true, inclusion: { in: BillViewHelper::LAW_CATEGORIES.keys }
  validates :classified_by, presence: true, inclusion: { in: %w[llm manual] }

  after_create :set_as_current_if_needed
  after_destroy :unset_current_if_needed

  private

  def set_as_current_if_needed
    bill.update_current_bill_category!(self)
  end

  def unset_current_if_needed
    if bill.current_bill_category_id == self.id
      bill.update_current_bill_category!
    end
  end
end
