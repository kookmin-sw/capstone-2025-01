class Bill < ApplicationRecord
  include BillStatus
  include BillTypes

  has_many :proposals
  has_many :proposers, through: :proposals
  has_one :bill_detail
  has_one :government_legislation_notice
  has_many :bill_summaries, dependent: :destroy

  # 각 Bill이 여러 bill_summaries 중 유저에게 노출할 것을 빠르게 참조할 수 있도록 역정규화 컬럼(current_bill_summary_id)을 사용
  belongs_to :current_bill_summary, class_name: "BillSummary", optional: true

  validates :bill_type, allow_nil: true, inclusion: { in: BillTypes::LIST.values }
  validates :assembly_bill_id, uniqueness: true, allow_nil: true

  scope :by_title, ->(query) { where("lower(title) LIKE ?", "%#{query.downcase}%") if query.present? }
  scope :by_bill_type, ->(bill_type) { where(bill_type: bill_type) if bill_type.present? }

  # bill_summaries 추가/삭제 시 current_bill_summary 자동 관리
  def update_current_bill_summary!(new_summary = nil)
    if auto_update_current_summary?
      summary = new_summary || bill_summaries.order(created_at: :desc).first
      update_column(:current_bill_summary_id, summary&.id)
    end
  end
end
