class Bill < ApplicationRecord
  belongs_to :department, optional: true

  has_many :bill_sponsors, dependent: :destroy
  has_many :sponsors, through: :bill_sponsors

  has_many :bill_events, dependent: :destroy
end
