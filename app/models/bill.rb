class Bill < ApplicationRecord
  belongs_to :department, optional: true

  has_many :bill_sponsors, dependent: :destroy
  has_many :sponsors, through: :bill_sponsors

  has_many :bill_events, dependent: :destroy

  # 정부입법인 경우
  validates :bill_type, inclusion: { in: %w[법률 대통령령 총리령 부령 대통령훈령 국무총리훈령] }, allow_nil: true
end
