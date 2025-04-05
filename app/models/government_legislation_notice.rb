class GovernmentLegislationNotice < ApplicationRecord
  belongs_to :bill, optional: true

  validates :law_card_id, uniqueness: true
end
