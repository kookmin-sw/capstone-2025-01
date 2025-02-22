class BillSponsor < ApplicationRecord
  belongs_to :bill
  belongs_to :sponsor

  validates :sponsor_role, inclusion: { in: %w[대표발의 공동발의] }, allow_nil: true
end
