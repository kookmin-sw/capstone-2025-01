class BillSummary < ApplicationRecord
  acts_as_paranoid

  belongs_to :bill
  belongs_to :editor, class_name: "User", optional: true

  validates :content, presence: true
  validates :summary_type, presence: true, inclusion: { in: %w[llm manual] }

  after_create :set_as_current_if_needed
  after_destroy :unset_current_if_needed

  def parse_heading_section
    return "" if content.blank?

    index = (content =~ /^###/)
    h2_section = index ? content[0...index] : content
    h2_section.gsub(/^##\s*/, "").strip
  end

  private

  def set_as_current_if_needed
    bill.update_current_bill_summary!(self)
  end

  def unset_current_if_needed
    if bill.current_bill_summary_id == self.id
      bill.update_current_bill_summary!
    end
  end
end
