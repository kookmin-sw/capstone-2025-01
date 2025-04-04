class GovernmentBillSponsor < ApplicationRecord
  has_many :proposals, as: :specific_proposer
end
