class BillSponsor < ApplicationRecord
  belongs_to :bill
  belongs_to :sponsor

  validates :sponsor_role, presence: true, inclusion: { in: %w[대표발의자 공동발의자 정부제출안] }
end
