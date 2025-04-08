class BillDetail < ApplicationRecord
  belongs_to :bill

  validates :bill_id, uniqueness: true
end
