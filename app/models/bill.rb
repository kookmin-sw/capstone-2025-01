class Bill < ApplicationRecord
  has_many :proposals
  has_many :proposers, through: :proposals
  has_one :bill_detail
  has_one :government_legislation_notice

  validates :bill_type, allow_nil: true, inclusion: { in: %w[헌법개정 예산안 결산 법률안 동의안 승인안 결의안 건의안 규칙안 선출안 중요동의 의원징계 윤리심사 의원자격심사 기타안 기타] }
  validates :assembly_bill_id, uniqueness: true, allow_nil: true

  scope :by_title, ->(query) { where("lower(title) LIKE ?", "%#{query.downcase}%") if query.present? }
  scope :by_bill_type, ->(bill_type) { where(bill_type: bill_type) if bill_type.present? }

  def received?
    current_status == "접수"
  end

  def reviewing?
    current_status == "심사"
  end

  def passed?
    current_status == "통과"
  end

  def rejected?
    current_status == "폐기"
  end

  def current_status
    case bill_stage
    when "소관위접수"
      "접수"
    when "소관위심사중", "법사위심사중"
      "심사"
    when "폐기"
      "폐기"
    when "공포", "통과"
      "통과"
    else
      "접수"
    end
  end

  # 상태에 따라 이모지 반환
  def status_emoji
    case current_status
    when "접수" then "📥 "
    when "심사" then "📝 "
    when "공포", "통과" then "✅ "
    when "폐기" then "❌ "
    else "📥 "
    end
  end

  # 상태에 따라 CSS 클래스 반환
  def status_css_class
    case current_status
    when "접수" then "status-received"
    when "심사" then "status-reviewing"
    when "공포", "통과" then "status-passed"
    when "폐기" then "status-discarded"
    else "status-received"
    end
  end
end
