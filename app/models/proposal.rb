class Proposal < ApplicationRecord
  belongs_to :bill
  belongs_to :specific_proposer, polymorphic: true

  scope :representative, -> { where(representative_proposal: true) }
end
