class Sponsor < ApplicationRecord
  # bills과 bill_sponsors 테이블을 통해 many-to-many 관계
  has_many :bill_sponsors, dependent: :destroy
  has_many :bills, through: :bill_sponsors

  validates :sponsor_type, presence: true, inclusion: { in: %w[국회입법 정부입법] }
  validates :name, presence: true
end
