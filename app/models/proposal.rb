class Proposal < ApplicationRecord
  belongs_to :bill
  belongs_to :proposer

  scope :representative, -> { where(representative_proposal: true) }
end
