class Bill < ApplicationRecord
  include BillStatus

  has_many :proposals
  has_many :proposers, through: :proposals
  has_one :bill_detail
  has_one :government_legislation_notice
  has_many :bill_summaries, dependent: :destroy

  # 각 Bill이 여러 bill_summaries 중 유저에게 노출할 것을 빠르게 참조할 수 있도록 역정규화 컬럼(current_bill_summary_id)을 사용
  belongs_to :current_bill_summary, class_name: "BillSummary", optional: true

  validates :bill_type, allow_nil: true, inclusion: { in: %w[헌법개정 예산안 결산 법률안 동의안 승인안 결의안 건의안 규칙안 선출안 중요동의 의원징계 윤리심사 의원자격심사 기타안 기타] }
  validates :assembly_bill_id, uniqueness: true, allow_nil: true

  scope :by_title, ->(query) { where("lower(title) LIKE ?", "%#{query.downcase}%") if query.present? }
  scope :by_bill_type, ->(bill_type) { where(bill_type: bill_type) if bill_type.present? }
end
